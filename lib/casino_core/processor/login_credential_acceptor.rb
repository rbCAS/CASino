require 'casino_core/processor'
require 'casino_core/helper'

# This processor should be used for POST requests to /login
class CASinoCore::Processor::LoginCredentialAcceptor < CASinoCore::Processor
  include CASinoCore::Helper::Logger
  include CASinoCore::Helper::LoginTickets
  include CASinoCore::Helper::ServiceTickets
  include CASinoCore::Helper::Authentication
  include CASinoCore::Helper::TicketGrantingTickets

  # Use this method to process the request. It expects the username in the parameter "username" and the password
  # in "password".
  #
  # The method will call one of the following methods on the listener:
  # * `#user_logged_in`: The first argument (String) is the URL (if any), the user should be redirected to.
  #   The second argument (String) is the ticket-granting ticket. It should be stored in a cookie named "tgt".
  # * `#invalid_login_ticket` and `#invalid_login_credentials`: The first argument is a LoginTicket.
  #   See {CASinoCore::Processor::LoginCredentialRequestor} for details.
  # * `#service_not_allowed`: The user tried to access a service that this CAS server is not allowed to serve.
  #
  # @param [Hash] params parameters supplied by user
  # @param [Hash] cookies cookies supplied by user
  # @param [String] user_agent user-agent delivered by the client
  def process(params = nil, cookies = nil, user_agent = nil)
    @params = params || {}
    @cookies = cookies || {}
    @user_agent = user_agent
    if login_ticket_valid?(@params[:lt])
      authenticate_user
    else
      @listener.invalid_login_ticket(acquire_login_ticket)
    end
  end

  private
  def authenticate_user
    authentication_result = validate_login_credentials(@params[:username], @params[:password])
    if !authentication_result.nil?
      user_logged_in(authentication_result)
    else
      @listener.invalid_login_credentials(acquire_login_ticket)
    end
  end

  def user_logged_in(authentication_result)
    begin
      ticket_granting_ticket = acquire_ticket_granting_ticket(authentication_result, @user_agent)
      url = unless @params[:service].nil?
        acquire_service_ticket(ticket_granting_ticket, @params[:service], true).service_with_ticket_url
      end
      @listener.user_logged_in(url, ticket_granting_ticket.ticket)
    rescue ServiceNotAllowedError => e
      @listener.service_not_allowed(clean_service_url @params[:service])
    end
  end
end
