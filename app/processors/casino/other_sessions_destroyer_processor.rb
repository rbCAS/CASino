# The OtherSessionsDestroyer processor should be used to process GET requests to /destroy-other-sessions.
#
# It is usefule to redirect users to this action after a password change.
#
# This feature is not described in the CAS specification so it's completly optional
# to implement this on the web application side.
class CASino::OtherSessionsDestroyerProcessor < CASino::Processor
  include CASino::ProcessorConcern::TicketGrantingTickets

  # This method will call `#other_sessions_destroyed` and may supply an URL that should be presented to the user.
  # The user should be redirected to this URL immediately.
  #
  # @param [Hash] params parameters supplied by user
  # @param [Hash] cookies cookies supplied by user
  # @param [String] user_agent user-agent delivered by the client
  def process(params = nil, cookies = nil, user_agent = nil)
    params ||= {}
    cookies ||= {}
    tgt = find_valid_ticket_granting_ticket(cookies[:tgt], user_agent)
    unless tgt.nil?
      other_ticket_granting_tickets = tgt.user.ticket_granting_tickets.where('id != ?', tgt.id)
      other_ticket_granting_tickets.destroy_all
    end
    @listener.other_sessions_destroyed(params[:service])
  end
end
