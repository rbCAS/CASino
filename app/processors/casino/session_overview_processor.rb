# The SessionOverview processor to list all open session for the currently signed in user.
#
# This feature is not described in the CAS specification so it's completly optional
# to implement this on the web application side.
class CASino::SessionOverviewProcessor < CASino::Processor
  include CASino::ProcessorConcern::TicketGrantingTickets

  # This method will call `#user_not_logged_in` or `#ticket_granting_tickets_found(Enumerable)` on the listener.
  # @param [Hash] cookies cookies delivered by the client
  # @param [String] user_agent user-agent delivered by the client
  def process(cookies = nil, user_agent = nil)
    cookies ||= {}
    tgt = find_valid_ticket_granting_ticket(cookies[:tgt], user_agent)
    if tgt.nil?
      @listener.user_not_logged_in
    else
      ticket_granting_tickets = tgt.user.ticket_granting_tickets.where(awaiting_two_factor_authentication: false).order('updated_at DESC')
      @listener.ticket_granting_tickets_found(ticket_granting_tickets)
    end
  end
end
