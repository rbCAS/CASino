class Cas::V1::TicketsController < ApplicationController

  # POST /cas/v1/tickets
  def create
    processor(:LoginCredentialAcceptor).process(params, cookies, request.user_agent)
  end

  # POST /cas/v1/tickets/{TGT id}
  def update

  end

  # DELETE /cas/v1/tickets/TGT-fdsjfsdfjkalfewrihfdhfaie
  def delete

  end

end
