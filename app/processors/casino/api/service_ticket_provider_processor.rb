# The ServiceTicketProvider processor should be used to handle API calls: POST requests to /cas/v1/tickets/<ticket_granting_ticket>
class CASino::API::ServiceTicketProviderProcessor < CASino::Processor
  include CASino::ProcessorConcern::ServiceTickets
  include CASino::ProcessorConcern::TicketGrantingTickets

  # Use this method to process the request.
  #
  # The method will call one of the following methods on the listener:
  # * `#granted_service_ticket_via_api`: First and only argument is a String with the service ticket.
  #   The service ticket (and nothing else) should be displayed.
  # * `#invalid_ticket_granting_ticket_via_api`: No argument. The application should respond with status "400 Bad Request"
  # * `#no_service_provided_via_api`: No argument. The application should respond with status "400 Bad Request"
  # * `#service_not_allowed_via_api`: The user tried to access a service that this CAS server is not allowed to serve.
  #
  # @param [String] ticket_granting_ticket ticket_granting_ticket supplied by the user in the URL
  # @param [Hash] parameters parameters supplied by user (`service` in particular)
  # @param [String] user_agent user-agent delivered by the client
  def process(ticket_granting_ticket, parameters = nil, user_agent = nil)
    parameters ||= {}
    @client_ticket_granting_ticket = ticket_granting_ticket
    @service_url = parameters[:service]
    @user_agent = user_agent

    fetch_valid_ticket_granting_ticket
    handle_ticket_granting_ticket
  end

  private
  def fetch_valid_ticket_granting_ticket
    @ticket_granting_ticket = find_valid_ticket_granting_ticket(@client_ticket_granting_ticket, @user_agent)
  end

  def handle_ticket_granting_ticket
    case
    when (@service_url and @ticket_granting_ticket)
      begin
        create_service_ticket
        callback_granted_service_ticket
      rescue ServiceNotAllowedError
        callback_service_not_allowed
      end
    when (@service_url and not @ticket_granting_ticket)
      callback_invalid_tgt
    when (not @service_url and @ticket_granting_ticket)
      callback_empty_service
    end
  end

  def create_service_ticket
    @service_ticket = acquire_service_ticket(@ticket_granting_ticket, @service_url)
  end

  def callback_granted_service_ticket
    @listener.granted_service_ticket_via_api @service_ticket.ticket
  end

  def callback_invalid_tgt
    @listener.invalid_ticket_granting_ticket_via_api
  end

  def callback_empty_service
    @listener.no_service_provided_via_api
  end

  def callback_service_not_allowed
    @listener.service_not_allowed_via_api(clean_service_url @service_url)
  end

end
