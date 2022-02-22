require "http"

class ProfileController < ApplicationController

  def index
    # First ensure we still have the tokens obtained during authentication and authorization.
    id_token = cookies.encrypted[:id_token]
    manage_token = cookies.encrypted[:manage_token]
    if id_token.blank? || manage_token.blank?
      redirect_to root_path
      return
    end

    # Then use the Clio Manage Access Token to make an API call. In this example we're getting some basic profile
    # information from the `api/v4/users/who_am_i` endpoint and displaying it on our profile page.
    params = {
      fields: "id,first_name,last_name,email,phone_number,account_owner"
    }
    response = HTTP.auth("Bearer " + manage_token).get(ENV["CLIO_MANAGE_SITE_URL"] + "api/v4/users/who_am_i?" + params.to_query)
    parsed_response = JSON.parse(response)

    if response.code != 200
      render "application/error", locals: {
        error_message: "Error getting who_am_i? response",
        error_info: parsed_response["error"]
      }
    end

    render "index", layout: "application", locals: {
      data: parsed_response["data"]
    }
  end

end
