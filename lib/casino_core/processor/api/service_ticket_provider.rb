require 'casino_core/processor'
require 'casino_core/helper'
require 'casino_core/model'
require 'casino_core/builder'

# The ServiceTicketProvider processor should be used to handle API calls: POST requests to /cas/v1/tickets/{TGT id}
class CASinoCore::Processor::API::ServiceTicketProvider < CASinoCore::Processor
  include CASinoCore::Helper::ServiceTickets
  include CASinoCore::Helper::TicketGrantingTickets


  def process(parameters)
    @client_ticket_granting_ticket = parameters[:ticket_granting_ticket]
    @service_url = parameters[:service]

    fetch_valid_ticket_granting_ticket
    handle_ticket_granting_ticket
  end

  private
  def fetch_valid_ticket_granting_ticket
    @ticket_granting_ticket = find_valid_ticket_granting_ticket(@client_ticket_granting_ticket, nil)
  end

  def handle_ticket_granting_ticket
    case
    when (@service_url and @ticket_granting_ticket)
      create_service_ticket
      callback_granted_service_ticket
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
    @listener.invalid_tgt_via_api
  end

  def callback_empty_service
    @listener.no_service_provided_via_api
  end

end
