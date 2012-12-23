class Cas::V1::TicketsController < ApplicationController

  # POST /cas/v1/tickets
  def create
    CASinoCore::Processor::LoginCredentialAcceptor.new(self).process(params, cookies, request.user_agent)
  end

  # POST /cas/v1/tickets/{TGT id}
  def update

  end

  # DELETE /cas/v1/tickets/TGT-fdsjfsdfjkalfewrihfdhfaie
  def delete

  end

  # callbacks
  def user_logged_in
    render nothing: true, status: 201
  end

end
