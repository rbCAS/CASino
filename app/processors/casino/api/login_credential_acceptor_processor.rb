# This processor should be used for API calls: POST /cas/v1/tickets
class CASino::API::LoginCredentialAcceptorProcessor < CASino::Processor
  include CASino::ProcessorConcern::ServiceTickets
  include CASino::ProcessorConcern::Authentication
  include CASino::ProcessorConcern::TicketGrantingTickets

  # Use this method to process the request. It expects the username in the parameter "username" and the password
  # in "password".
  #
  # The method will call one of the following methods on the listener:
  # * `#user_logged_in_via_api`: First and only argument is a String with the TGT-id
  # * `#invalid_login_credentials_via_api`: No argument
  #
  # @param [Hash] login_data parameters supplied by user (username and password)
  def process(login_data, user_agent = nil)
    @login_data = login_data
    @user_agent = user_agent

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
    @ticket_granting_ticket = acquire_ticket_granting_ticket(@authentication_result, @user_agent)
  end

  def callback_invalid_login_credentials
    @listener.invalid_login_credentials_via_api
  end

end
