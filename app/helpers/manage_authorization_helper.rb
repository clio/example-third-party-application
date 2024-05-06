module ManageAuthorizationHelper

  def manage_authorize_url(state)
    params = {
      response_type: "code",
      client_id: ENV["CLIO_MANAGE_CLIENT_ID"],
      redirect_uri: ENV["ROOT_URL"] + "manage_callback",
      state: state,
      redirect_on_decline: true
    }
    ENV["CLIO_MANAGE_SITE_URL"] + "oauth/authorize?" + params.to_query
  end

  def manage_token_url
    ENV["CLIO_MANAGE_SITE_URL"] + "oauth/token?"
  end

  def manage_token_body(code)
    {
      client_id: ENV["CLIO_MANAGE_CLIENT_ID"],
      client_secret: ENV["CLIO_MANAGE_CLIENT_SECRET"],
      grant_type: "authorization_code",
      code: code,
      redirect_uri: ENV["ROOT_URL"] + "manage_callback"
    }
  end

  def manage_state_valid?(manage_state)
    manage_state.present? && manage_state == cookies.encrypted[:manage_state]
  end

end
