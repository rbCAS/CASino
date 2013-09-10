require 'casino_core/processor'
require 'casino_core/helper'

# The Logout processor should be used to process API DELETE requests to /cas/v1/tickets/<ticket_granting_ticket>
class CASinoCore::Processor::API::Logout < CASinoCore::Processor
  include CASinoCore::Helper::TicketGrantingTickets

  # This method will call `#user_logged_out_via_api` on the listener.
  #
  # @param [String] ticket_granting_ticket Ticket-granting ticket to logout
  def process(ticket_granting_ticket, user_agent = nil)
    remove_ticket_granting_ticket(ticket_granting_ticket, user_agent)
    callback_user_logged_out
  end

  def callback_user_logged_out
    @listener.user_logged_out_via_api
  end

end
