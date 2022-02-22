require "http"

class MatterController < ApplicationController

  def index
    # First ensure we still have the tokens obtained during authentication and authorization.
    id_token = cookies.encrypted[:id_token]
    manage_token = cookies.encrypted[:manage_token]
    if id_token.blank? || manage_token.blank?
      redirect_to root_path
      return
    end

    # In this example we're getting the firms Matters using Unlimited Cursor Pagination
    # https://app.clio.com/api/v4/documentation#section/Matters
    # https://app.clio.com/api/v4/documentation#section/Paging/Unlimited-Cursor-Pagination
    params = {
      fields: "display_number,description,status",
      status: "open",
      limit: 10,
      order: "id(asc)"
    }
    response = HTTP.auth("Bearer " + cookies.encrypted[:manage_token]).get(ENV["CLIO_MANAGE_SITE_URL"] + "api/v4/matters?" + params.to_query)

    handle_matters_response(response)
  end

  def paginate
    new_page_url = params[:page]
    response = HTTP.auth("Bearer " + cookies.encrypted[:manage_token]).get(new_page_url)
    handle_matters_response(response)
  end

  private

  def handle_matters_response(response)
    parsed_response = JSON.parse(response)

    if response.code != 200
      render "application/error", locals: {
        error_message: "Error getting matters response",
        error_info: parsed_response["error"]
      }
    end

    render "index", layout: "application", locals: {
      paging: parsed_response["meta"]["paging"],
      matters: parsed_response["data"]
    }
  end

end
