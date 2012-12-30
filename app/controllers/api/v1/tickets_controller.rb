class API::V1::TicketsController < ApplicationController

  # POST /cas/v1/tickets
  def create
    CASinoCore::Processor::API::LoginCredentialAcceptor.new(self).process(params)
  end

  # POST /cas/v1/tickets/{TGT id}
  def update
  end

  # DELETE /cas/v1/tickets/TGT-fdsjfsdfjkalfewrihfdhfaie
  def delete

  end

  # callbacks
  def user_logged_in_via_api(ticket_granting_ticket)
    render nothing: true, status: 201, location: api_v1_ticket_url(ticket_granting_ticket)
  end

  def invalid_login_credentials_via_api
    render nothing: true, status: 400
  end

end
