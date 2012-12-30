require 'casino_core/processor/api'
require 'casino_core/helper'

# This processor should be used for API calls: POST /cas/v1/tickets
class CASinoCore::Processor::API::LoginCredentialAcceptor < CASinoCore::Processor
  include CASinoCore::Helper::Logger
  include CASinoCore::Helper::ServiceTickets
  include CASinoCore::Helper::Authentication
  include CASinoCore::Helper::TicketGrantingTickets

  # Use this method to process the request. It expects the username in the parameter "username" and the password
  # in "password".
  #
  # The method will call one of the following methods on the listener:
  # * `#api_user_logged_in`:
  # * `#api_invalid_login_credentials`:
  #
  # @param [Hash] params parameters supplied by user
  # @param [Hash] cookies cookies supplied by user
  # @param [String] user_agent user-agent delivered by the client
  def process(login_data)
    @login_data = login_data

    validate_login_data

    unless @authentication_result.nil?
      generate_ticket_granting_ticket
      callback_user_logged_in
    else
      callback_invalid_login_credentials
    end
  end

  private
  def validate_login_data
    @authentication_result = validate_login_credentials(@login_data[:username], @login_data[:password])
  end

  def callback_user_logged_in
    @listener.user_logged_in_via_api @ticket_granting_ticket.ticket
  end

  def generate_ticket_granting_ticket
    @ticket_granting_ticket = acquire_ticket_granting_ticket(@authentication_result)
  end

  def callback_invalid_login_credentials
    @listener.invalid_login_credentials_via_api
  end

end
