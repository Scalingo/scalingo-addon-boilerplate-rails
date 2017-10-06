class Scalingo::ResourcesController < ApplicationController
  # To have the `authenticate_with_http_basic` function
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  before_action :addon_protected!

  # Endpoint requested when addon is provisioned
  # Params look like
  # {
  #   "uuid": "d7bbc18b-e454-45c1-89cd-b3cc5587fdc4",
  #   "plan": "plan-name",
  #   "options": {
  #     "opt-1": "val-1",
  #     "opt-2": "val-2"
  #   }
  # }
  # Options are defined in the addon manifest provided to Scalingo
  # Should return 200 and 201 for synchronous validation
  # Should return 202 for asynchronous validation
  def create
    addon_params = create_params
  end

  # Endpoint requested when the user resumes an addon (after account suspension/end of free trial)
  # No body, only :resource_id URL param.
  # Should return 204 No content
  def resume
    resource_id = params[:resource_id]
    head :no_content
  end

  # In case of payment failure/end of free trial without having a payment method
  # The addon should be suspended.
  # No body, only :resource_id URL param.
  # Should return 204 No content
  def suspend
    resource_id = params[:resource_id]
    head :no_content
  end

  # Endpoint requested when the user changes the plan of an addon
  # Body looks like
  # {
  #   "plan": "new-plan"
  # }
  # Should return 200 for synchronous update
  # Should return 202 for asychronous update
  def update
    resource_id = params[:id]

    if !params.has_key? "plan"
      return render json: {"error": "update resource need a plan"}.to_json, status: 422
    end
  end

  # Endpoint requested when an addon is deleted
  # No body
  # Should return 204 No Content
  def destroy
    resource_id = params[:id]
    head :no_content
  end

  private

  def create_params
    params.permit(:plan, :uuid, options: {})
  end

  def addon_protected!
    if Rails.env != "development" and !authenticate_with_http_basic { |u,p|
      u == ENV["ADDON_USER"] && p.start_with?(ENV["ADDON_PASSWD"])
    }
      request_http_basic_authentication
    end
  end
end
