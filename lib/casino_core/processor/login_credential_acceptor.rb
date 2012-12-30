require 'casino_core/processor'
require 'casino_core/helper'

# This processor should be used for POST requests to /login
class CASinoCore::Processor::LoginCredentialAcceptor < CASinoCore::Processor
  include CASinoCore::Helper::Logger
  include CASinoCore::Helper::LoginTickets
  include CASinoCore::Helper::ServiceTickets

  # Use this method to process the request. It expects the username in the parameter "username" and the password
  # in "password".
  #
  # The method will call one of the following methods on the listener:
  # * `#user_logged_in`: The first argument (String) is the URL (if any), the user should be redirected to.
  #   The second argument (String) is the ticket-granting ticket. It should be stored in a cookie named "tgt".
  # * `#invalid_login_ticket` and `#invalid_login_credentials`: The first argument is a LoginTicket.
  #   See {CASinoCore::Processor::LoginCredentialRequestor} for details.
  #
  # @param [Hash] params parameters supplied by user
  # @param [Hash] cookies cookies supplied by user
  # @param [String] user_agent user-agent delivered by the client
  def process(params = nil, cookies = nil, user_agent = nil)
    params ||= {}
    cookies ||= {}
    if login_ticket_valid?(params[:lt])
      authentication_result = validate_login_credentials(params[:username], params[:password])
      if !authentication_result.nil?
        ticket_granting_ticket = acquire_ticket_granting_ticket(authentication_result, user_agent)
        url = unless params[:service].nil?
          acquire_service_ticket(ticket_granting_ticket, params[:service], true).service_with_ticket_url
        end
        @listener.user_logged_in(url, ticket_granting_ticket.ticket)
      else
        @listener.invalid_login_credentials(acquire_login_ticket)
      end
    else
      @listener.invalid_login_ticket(acquire_login_ticket)
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
    authentication_result = nil
    CASinoCore::Settings.authenticators.each do |authenticator_name, authenticator|
      data = authenticator.validate(username, password)
      if data
        authentication_result = { authenticator: authenticator_name, user_data: data }
        logger.info("Credentials for username '#{data[:username]}' successfully validated using authenticator '#{authenticator_name}' (#{authenticator.class})")
        break
      end
    end
    authentication_result
  end

  def acquire_ticket_granting_ticket(authentication_result, user_agent = nil)
    user_data = authentication_result[:user_data]
    CASinoCore::Model::TicketGrantingTicket.create!({
      ticket: random_ticket_string('TGC'),
      authenticator: authentication_result[:authenticator],
      username: user_data[:username],
      extra_attributes: user_data[:extra_attributes],
      user_agent: user_agent
    })
  end
end
