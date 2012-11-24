require 'casino/authenticator'

class SessionsController < ApplicationController
  include SessionsHelper

  before_filter :validate_login_ticket, only: :create

  def index
    unless signed_in?
      return redirect_to new_session_path
    end
  end

  def new
  end

  def create
    login_data = validate_login(params[:username], params[:password])
    if login_data
      ticket_granting_ticket = acquire_ticket_granting_ticket(login_data[:username], login_data[:extra_attributes])
      cookies[:tgt] = ticket_granting_ticket.ticket
      logger.info "Successfully generated ticket-granting ticket for user '#{login_data[:username]}'"
      if params[:service].nil?
        redirect_to sessions_path
      else
        redirect_to params[:serivce]
      end
    else
      logger.info "Could not login user '#{params[:username]}': Invalid credentials supplied."
      flash[:error] = 'Incorrect username or password.'
      render 'new', status: 403
    end
  end
end
