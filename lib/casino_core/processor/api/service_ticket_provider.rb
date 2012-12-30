require 'casino_core/processor'
require 'casino_core/helper'
require 'casino_core/model'
require 'casino_core/builder'

# The ServiceTicketProvider processor should be used to handle API calls: POST requests to /cas/v1/tickets/{TGT id}
class CASinoCore::Processor::API::ServiceTicketProvider < CASinoCore::Processor
  include CASinoCore::Helper::ServiceTickets
  include CASinoCore::Helper::TicketGrantingTickets


  def process(ticket_granting_ticket, service_url)
    @client_ticket_granting_ticket = ticket_granting_ticket
    @service_url = service_url

    fetch_valid_ticket_granting_ticket
    handle_ticket_granting_ticket
  end

  private
  def fetch_valid_ticket_granting_ticket
    @ticket_granting_ticket = find_valid_ticket_granting_ticket(@client_ticket_granting_ticket, nil)
  end

  def handle_ticket_granting_ticket
    if @ticket_granting_ticket
      create_service_ticket
      @listener.granted_service_ticket_via_api @service_ticket.ticket
    else
      @listener.invalid_tgt_via_api
    end
  end

  def create_service_ticket
    @service_ticket = acquire_service_ticket(@ticket_granting_ticket, @service_url)
  end

end
