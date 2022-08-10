require "http"

class MatterController < ApplicationController

  before_action :require_manage_token

  def index
    # In this example we're getting the firms Matters using Unlimited Cursor Pagination
    # https://app.clio.com/api/v4/documentation#operation/Matter#index
    # https://app.clio.com/api/v4/documentation#section/Paging/Unlimited-Cursor-Pagination
    params = {
      fields: "id,display_number,description,status",
      status: "open",
      limit: 10,
      order: "id(asc)"
    }
    response = HTTP.auth("Bearer " + @manage_token).get(ENV["CLIO_MANAGE_SITE_URL"] + "api/v4/matters?" + params.to_query)

    handle_matters_response(response)
  end

  def paginate
    new_page_url = params[:page]
    response = HTTP.auth("Bearer " + @manage_token).get(new_page_url)
    handle_matters_response(response)
  end

  def show
    # In this example we're getting all attributes of a single Matter
    # https://app.clio.com/api/v4/documentation#operation/Matter#show
    matter_id = params[:id]
    if matter_id.blank?
      redirect_to root_path
      return
    end

    params = {
      fields: "id,etag,number,display_number,custom_number,description,status,location,client_reference,client_id,billable,maildrop_address,billing_method,open_date,close_date,pending_date,created_at,updated_at,shared,has_tasks,client,contingency_fee,custom_rate,evergreen_retainer,folder,group,matter_budget,originating_attorney,practice_area,responsible_attorney,statute_of_limitations,user,account_balances,custom_field_values,custom_field_set_associations,relationships,task_template_list_instances"
    }
    response = HTTP.auth("Bearer " + @manage_token).get(ENV["CLIO_MANAGE_SITE_URL"] + "api/v4/matters/" + matter_id + "?" + params.to_query)

    handle_matter_response(response)
  end

  private

  def handle_matters_response(response)
    parsed_response = JSON.parse(response)

    if response.code != 200
      render_error("Error getting matters response", parsed_response["error"])
      return
    end

    render "index", locals: {
      paging: parsed_response["meta"]["paging"],
      matters: parsed_response["data"]
    }
  end

  def handle_matter_response(response)
    parsed_response = JSON.parse(response)

    if response.code != 200
      render_error("Error getting single matter response", parsed_response["error"])
      return
    end

    render "show", locals: {
      matter: parsed_response["data"],
      back: params[:back] || matter_index_path
    }
  end
end
