class CASino::Api::V1::TicketsController < CASino::ApplicationController

  # POST /cas/v1/tickets
  def create
    CASino::API::LoginCredentialAcceptorProcessor.new(self).process(params, request.user_agent)
  end

  # POST /cas/v1/tickets/{TGT id}
  def update
    CASino::API::ServiceTicketProviderProcessor.new(self).process(params[:id], params, request.user_agent)
  end

  # DELETE /cas/v1/tickets/TGT-fdsjfsdfjkalfewrihfdhfaie
  def destroy
    CASino::API::LogoutProcessor.new(self).process(params[:id], request.user_agent)
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

  def service_not_allowed_via_api
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

# Inflector alias
CASino::API = CASino::Api
