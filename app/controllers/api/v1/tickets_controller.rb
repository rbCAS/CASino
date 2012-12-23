class API::V1::TicketsController < ApplicationController

  # POST /cas/v1/tickets
  def create
    CASinoCore::Processor::LoginCredentialRequestor.new(self).process(params, cookies, request.user_agent)
  end

  # POST /cas/v1/tickets/{TGT id}
  def update
    CASinoCore::Processor::LoginCredentialAcceptor.new(self).process(params, cookies, request.user_agent)
  end

  # DELETE /cas/v1/tickets/TGT-fdsjfsdfjkalfewrihfdhfaie
  def delete

  end

  # callbacks
  def user_logged_in(url, ticket_granting_ticket)
    render nothing: true, status: 201, location: api_v1_ticket_url(ticket_granting_ticket)
  end

  def invalid_login_credentials(login_ticket)
    render nothing: true, status: 400
  end

end
