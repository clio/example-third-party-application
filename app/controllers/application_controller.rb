require "http"

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include IdentityAuthenticationHelper
  include ManageAuthorizationHelper

  # This method is performing the steps under "Obtaining Authorization" in the Integrating with Clio Identity documentation:
  # https://developers.support.clio.com/hc/en-us/articles/4405288237723-Integrating-with-Clio-Identity-Single-Sign-on-with-Clio-
  #
  # This will send the user to the Clio Identity Account page where they will log in and be given the option to grant
  # your application permission to access their Clio Identity information. After they have allowed access they will be
  # redirected to the specified redirect URI in this request. In this example that is `identity_callback` seen below.
  def authenticate_with_identity
    identity_state = SecureRandom.hex
    cookies.encrypted[:identity_state] = {
      value: identity_state,
      same_site: "None",
      secure: true,
    }

    redirect_to identity_authenticate_url(identity_state), allow_other_host: true
  end

  # This method is performing the steps under "Grant Approved" in the Integrating with Clio Identity documentation:
  # https://developers.support.clio.com/hc/en-us/articles/4405288237723-Integrating-with-Clio-Identity-Single-Sign-on-with-Clio-
  def identity_callback
    # First we ensure that the previous step was successful: the state is the same as what we sent in the previous
    # request and that we did successfully obtain a code.
    if !identity_state_valid?(params[:state])
      render_identity_error("bad state", params.to_unsafe_h)
      return
    end
    if !params.has_key?(:code)
      render_identity_error("missing code", params.to_unsafe_h)
      return
    end

    # Then we make a request for the Clio Identity related information from the users account.
    response = HTTP.post(identity_token_url, form: identity_token_body(params[:code]))
    parsed_response = JSON.parse(response.body)

    # Make sure to handle any error cases, such as if authentication fails or the user revokes
    # your applications access grant.
    if response.code != 200
      render_identity_error("error getting id token", parsed_response)
      return
    end

    # The response has to be decoded (using the RS256 algorithm) and then validated (following
    # the Open ID specs).
    decoded_token = decode_and_validate_identity_token(parsed_response["id_token"])

    # If validation passes, save the `id_token` for later use and move on to requesting
    # authorization in Manage.
    cookies.encrypted[:id_token] = {
      value: decoded_token,
      same_site: "None",
      secure: true,
    }
    authorize_with_manage
  rescue JwtDecodeError => e
    render_identity_error("JWT decode error", e.message)
  rescue JsonWebKeyError => e
    render_identity_error("error getting JSON web keys", JSON.parse(e.message))
  rescue InvalidTokenError => e
    render_identity_error("invalid token", e.message)
  end

  # This method is performing the steps in step 1 of "Grant Type: Authorization Code" under "Obtaining Authorization"
  # in the Clio API Documentation: https://app.clio.com/api/v4/documentation#section/Authorization-with-OAuth-2.0/Obtaining-Authorization
  #
  # This will send the user to the Clio Manage Authorization page where they will log in and be given the option to
  # grant your application permission to access their Clio Manage information. After they have allowed access they will
  # be redirected to the specified redirect URI in this request. In this example that is `manage_callback` seen below.
  def authorize_with_manage
    manage_state = SecureRandom.hex
    cookies.encrypted[:manage_state] = {
      value: manage_state,
      same_site: "None",
      secure: true,
    }
    redirect_to manage_authorize_url(manage_state), allow_other_host: true
  end

  # This method is performing the steps in step 2 of "Grant Type: Authorization Code" under "Obtaining Authorization"
  # in the Clio API Documentation: https://app.clio.com/api/v4/documentation#section/Authorization-with-OAuth-2.0/Obtaining-Authorization
  def manage_callback
    # If `redirect_on_decline` was set to `true` in the first request we can verify that permission was granted in
    # the first step of Manage authorization. Here we also ensure that the state is the same as what we sent and
    # that we did successfully obtain a code.
    if params.has_key?(:error)
      render_manage_error(params[:error].sub("_", " "), params.to_unsafe_h)
      return
    end
    if !manage_state_valid?(params[:state])
      render_manage_error("bad state", params.to_unsafe_h)
      return
    end
    if !params.has_key?(:code)
      render_manage_error("missing code", params.to_unsafe_h)
      return
    end

    # Then we make a request for the Clio Manaage access token.
    response = HTTP.headers("Content-Type" => "application/x-www-form-urlencoded").post(manage_token_url, form: manage_token_body(params[:code]))
    parsed_response = JSON.parse(response.body)

    # Make sure to handle any error cases.
    if response.code != 200
      render_manage_error("error getting access token", parsed_response)
      return
    end

    # And save the `access_token` for future Manage API requests. Access tokens have a limited lifespan and will
    # eventually expire. The expiry date and time can be calulcated with the `expires_in` value from the response
    # (which is the lifepsan in seconds). You may want to save the `refresh_token` to refresh your access once the
    # access token expires. More information on refresh tokens can be found in the Clio API Documentation:
    # https://app.clio.com/api/v4/documentation#section/Authorization-with-OAuth-2.0/Oauth-Refresh-Tokens
    cookies.encrypted[:manage_token] = {
      value: parsed_response["access_token"],
      same_site: "None",
      secure: true,
    }

    # Now your user is fully authenticated and authorized!
    #
    # When a user adds your app to Clio Manage from the App Directory you are required to redirect them to a
    # Clio Manage callback page (not your applications dashboard). This ensures that the user returns back to
    # the App Directory where they started. At this point in time, after the authentication and authorization
    # is complete, you'd create their account within your application before issuing this redirect. You can
    # read more about this process in this support article:
    # https://developers.support.clio.com/hc/en-us/articles/4405283081627
    #
    # Rather than implementing SSO twice, once for the usual SSO login flow and once for the "Add to Clio" flow
    # from the App Directory, we use a query parameter and cookie to distinguish between the two. The "Add to Clio"
    # URL we would provide for this example app would look something like https://myapp.com/welcome?install_flow=1.
    # On the welcome page this query parameter is saved in a cookie and here we use it to determine next steps.
    #
    # If we are performing the "Add to Clio" flow we need to create the user and their account within our
    # application then redirect to the Clio Manage callback page. If we performing the usual SSO login flow
    # we need to redirect them to our apps dashboard, which in this example is the profile page.
    if cookies.encrypted[:install_flow] == "1"
      # Create user/account in your application here
      redirect_to ENV["CLIO_MANAGE_SITE_URL"] + "app_integrations_callback", allow_other_host: true
    else
      redirect_to "/auth_popup_callback"
    end
  end

  # Upon succesful callback, we send a message to the main window
  def auth_popup_callback
    render plain: "<script>window.opener.postMessage('authentication_successful', '" + ENV["ROOT_URL"] + "');window.close();</script>", content_type: "text/html"
  end

  def signout
    cookies.delete :manage_token
    cookies.delete :id_token
    cookies.delete :identity_state
    cookies.delete :manage_state
    redirect_to root_path
  end

  private

  def render_identity_error(message, info)
    render_error("Clio Identity authentication failed: " + message, info)
  end

  def render_manage_error(message, info)
    render_error("Clio Manage authorization failed: " + message, info)
  end

  def render_error(message, info)
    render "error", locals: {
      error_message: message,
      error_info: info
    }
  end

  def require_manage_token
    # Ensure we still have the tokens obtained during authentication and authorization.
    @id_token = cookies.encrypted[:id_token]
    @manage_token = cookies.encrypted[:manage_token]

    if @id_token.blank? || @manage_token.blank?
      redirect_to root_path
    end
  end
end
