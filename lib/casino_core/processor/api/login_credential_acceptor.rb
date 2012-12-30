require 'casino_core/processor/api'
require 'casino_core/helper'

# This processor should be used for API calls: POST /cas/v1/tickets
class CASinoCore::Processor::API::LoginCredentialAcceptor < CASinoCore::Processor
  include CASinoCore::Helper::Logger
  include CASinoCore::Helper::ServiceTickets

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
