require 'casino/authenticator'

class SessionsController < ApplicationController
  include SessionsHelper

  before_filter :validate_login_ticket, only: :create
  before_filter :authenticate, only: :index

  def index
    @ticket_granting_tickets = TicketGrantingTicket.where(username: current_ticket_granting_ticket.username).order('updated_at DESC')
  end

  def new
    service = params[:service]
    if service.nil?
      if signed_in?
        redirect_to sessions_path
      end
    else
      if params[:renew]
        logger.debug 'Single-sign on bypassed, renew requested'
      elsif signed_in?
        generate_service_ticket_and_redirect(service)
      end
    end
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
        generate_service_ticket_and_redirect(params[:service], true)
      end
    else
      logger.info "Could not login user '#{params[:username]}': Invalid credentials supplied."
      flash.now[:error] = 'Incorrect username or password.'
      render 'new', status: 403
    end
  end

  def destroy
    ticket_granting_ticket = TicketGrantingTicket.find params[:id]
    if ticket_granting_ticket.username != current_ticket_granting_ticket.username
      logger.info "Did not allow '#{ticket_granting_ticket.username}' to delete ticket owned by #{current_ticket_granting_ticket.username}"
    elsif !current_ticket_granting_ticket?(ticket_granting_ticket)
      destroy_ticket_granting_ticket(ticket_granting_ticket)
    end
    redirect_to sessions_path
  end

  def logout
    if signed_in?
      destroy_ticket_granting_ticket(current_ticket_granting_ticket)
      cookies.delete(:tgt)
    end
    if params[:url].blank?
      redirect_to login_path, notice: 'You successfuly logged out.'
    else
      @url = params[:url]
    end
  end

  private
  def authenticate
    deny_access unless signed_in?
  end

  def deny_access
    flash.now[:error] = 'Please sign in to access this page.'
    render 'new', status: 403
  end

  def redirect_signed_in
    redirect_to sessions_path if signed_in?
  end

  def validate_login(username, password)
    user_data = nil
    Yetting.authenticators.each do |authenticator|
      instance = "#{authenticator['class']}".constantize.new(authenticator['options'])
      data = instance.validate(username, password)
      if data
        if data[:username].nil?
          data[:username] = username
        end
        user_data = data
        logger.info("Credentials for username '#{data[:username]}' successfully validated using #{authenticator['class']}")
        break
      end
    end
    user_data
  end

  def validate_login_ticket
    login_ticket = params[:lt]
    ticket = LoginTicket.find_by_ticket login_ticket
    valid = if ticket.nil?
      logger.info "Login ticket '#{login_ticket}' not found"
      false
    elsif ticket.created_at < Yetting.login_ticket['lifetime'].seconds.ago
      logger.info "Login ticket '#{ticket.ticket}' expired"
      false
    else
      logger.debug "Login ticket '#{ticket.ticket}' successfully validated"
      ticket.delete
      true
    end
    unless valid
      flash.now[:error] = 'No valid login ticket found. Please try again.'
      render 'new', status: 403
    end
  end

  def acquire_ticket_granting_ticket(username, extra_attributes = nil)
    TicketGrantingTicket.create!({
      ticket: random_ticket_string('TGC'),
      username: username,
      extra_attributes: extra_attributes,
      user_agent: request.env['HTTP_USER_AGENT']
    })
  end

  def destroy_ticket_granting_ticket(ticket_granting_ticket)
    ticket_granting_ticket.destroy
  end

  def acquire_service_ticket(service)
    current_ticket_granting_ticket.service_tickets.create!({
      ticket: random_ticket_string('ST'),
      service: service
    })
  end

  def generate_service_ticket_and_redirect(service, credentials_supplied = nil)
    service = clean_service_url(service)
    service_ticket = acquire_service_ticket(service)
    if credentials_supplied
      service_ticket.issued_from_credentials = credentials_supplied
      service_ticket.save!
    end
    redirect_to service_with_ticket_url(service, service_ticket), status: :see_other
  end

  def service_with_ticket_url(service, service_ticket)
    service_uri = URI.parse(service)
    if service.include? '?'
      if service_uri.query.empty?
        query_separator = ''
      else
        query_separator = '&'
      end
    else
      query_separator = '?'
    end
    service + query_separator + 'ticket=' + service_ticket.ticket
  end
end
