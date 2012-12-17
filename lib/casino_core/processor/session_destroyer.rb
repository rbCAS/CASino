require 'casino_core/processor'
require 'casino_core/helper'
require 'casino_core/model'

# The SessionDestroyer processor is used to destroy a ticket-granting ticket.
#
# This feature is not described in the CAS specification so it's completly optional
# to implement this on the web application side. It is especially useful in
# combination with the {CASinoCore::Processor::SessionOverview} processor.
class CASinoCore::Processor::SessionDestroyer < CASinoCore::Processor

  # This method will call `#ticket_not_found` or `#ticket_deleted` on the listener.
  # @param [String] tgt ticket-granting ticket
  def process(tgt)
    ticket = CASinoCore::Model::TicketGrantingTicket.where(ticket: tgt).first
    if ticket.nil?
      @listener.ticket_not_found
    else
      ticket.destroy
      @listener.ticket_deleted
    end
  end
end
