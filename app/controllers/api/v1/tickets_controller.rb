class API::V1::TicketsController < ApplicationController

  # POST /cas/v1/tickets
  def create
    CASinoCore::Processor::API::LoginCredentialAcceptor.new(self).process(params)
  end

  # POST /cas/v1/tickets/{TGT id}
  def update
    CASinoCore::Processor::API::ServiceTicketProvider.new(self).process(params[:id], {service: params[:service]})
  end

  # DELETE /cas/v1/tickets/TGT-fdsjfsdfjkalfewrihfdhfaie
  def destroy
    CASinoCore::Processor::API::Logout.new(self).process(params[:id])
  end

  # callbacks
  def user_logged_in_via_api(ticket_granting_ticket)
    render nothing: true, status: 201, location: api_v1_ticket_url(ticket_granting_ticket)
  end

  def invalid_login_credentials_via_api
    error_response
  end

  def granted_service_ticket_via_api(service_ticket)
    render text: service_ticket, status: 200, content_type: Mime::TEXT
  end

  def invalid_ticket_granting_ticket_via_api
    error_response
  end

  def no_service_provided_via_api
    error_response
  end

  def user_logged_out_via_api
    render nothing: true, status: 200
  end

  private
  def error_response
    render nothing: true, status: 400
  end



end
