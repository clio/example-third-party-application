require "http"

class ProfileController < ApplicationController

  before_action :require_manage_token

  def index
    # Then use the Clio Manage Access Token to make an API call. In this example we're getting some basic profile
    # information from the `api/v4/users/who_am_i` endpoint and displaying it on our profile page.
    params = {
      fields: "id,first_name,last_name,email,phone_number,account_owner"
    }

    response = HTTP.auth("Bearer " + @manage_token).get(ENV["CLIO_MANAGE_SITE_URL"] + "api/v4/users/who_am_i?" + params.to_query)
    parsed_response = JSON.parse(response)

    if response.code != 200
      render_error("Error getting who_am_i? response", parsed_response["error"])
      return
    end

    render "index", locals: {
      data: parsed_response["data"]
    }
  end

end
