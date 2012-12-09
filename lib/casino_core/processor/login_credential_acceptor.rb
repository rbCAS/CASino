require 'casino_core/processor'
require 'casino_core/helper'

class CASinoCore::Processor::LoginCredentialAcceptor < CASinoCore::Processor
  include CASinoCore::Helper
  include CASinoCore::Helper::ServiceTickets

  def process(params = nil, cookies = nil, request_env = nil)
    params ||= {}
    cookies ||= {}
    if login_ticket_valid?(params[:lt])
      user_data = validate_login_credentials(params[:username], params[:password])
      if !user_data.nil?
        ticket_granting_ticket = acquire_ticket_granting_ticket(user_data, request_env)
        url = if params[:service].nil?
          nil
        else
          acquire_service_ticket(ticket_granting_ticket, params[:service], true).service_with_ticket_url
        end
        @listener.user_logged_in(url, ticket_granting_ticket.ticket)
      else
        @listener.invalid_login_credentials
      end
    else
      @listener.invalid_login_ticket
    end
  end

  private
  def login_ticket_valid?(lt)
    ticket = CASinoCore::Model::LoginTicket.find_by_ticket lt
    if ticket.nil?
      logger.info "Login ticket '#{lt}' not found"
      false
    elsif ticket.created_at < CASinoCore::Settings.login_ticket[:lifetime].seconds.ago
      logger.info "Login ticket '#{ticket.ticket}' expired"
      false
    else
      logger.debug "Login ticket '#{ticket.ticket}' successfully validated"
      ticket.delete
      true
    end
  end

  def validate_login_credentials(username, password)
    user_data = nil
    CASinoCore::Settings.authenticators.each do |authenticator|
      data = authenticator.validate(username, password)
      if data
        if data[:username].nil?
          data[:username] = username
        end
        user_data = data
        logger.info("Credentials for username '#{data[:username]}' successfully validated using #{authenticator.class}")
        break
      end
    end
    user_data
  end

  def acquire_ticket_granting_ticket(user_data, request_env = nil)
    CASinoCore::Model::TicketGrantingTicket.create!({
      ticket: random_ticket_string('TGC'),
      username: user_data[:username],
      extra_attributes: user_data[:extra_attributes],
      user_agent: (request_env.nil? ? nil : request_env['HTTP_USER_AGENT'])
    })
  end
end
