# The SessionDestroyer processor is used to destroy a ticket-granting ticket.
#
# This feature is not described in the CAS specification so it's completly optional
# to implement this on the web application side. It is especially useful in
# combination with the {CASino::SessionOverviewProcessor} processor.
class CASino::SessionDestroyerProcessor < CASino::Processor

  # This method will call `#ticket_not_found` or `#ticket_deleted` on the listener.
  # @param [Hash] params parameters supplied by user (ID of ticket-granting ticket to delete should by in params[:id])
  # @param [Hash] cookies cookies supplied by user
  # @param [String] user_agent user-agent delivered by the client
  def process(params = nil, cookies = nil, user_agent = nil)
    params ||= {}
    cookies ||= {}
    ticket = CASino::TicketGrantingTicket.where(id: params[:id]).first
    owner_ticket = CASino::TicketGrantingTicket.where(ticket: cookies[:tgt]).first
    if ticket.nil? || !ticket.same_user?(owner_ticket)
      @listener.ticket_not_found
    else
      Rails.logger.info "Destroying ticket-granting ticket '#{ticket.ticket}'"
      ticket.destroy
      @listener.ticket_deleted
    end
  end
end
