require 'casino_core/processor'
require 'casino_core/helper'
require 'casino_core/model'

class CASinoCore::Processor::Logout < CASinoCore::Processor
  include CASinoCore::Helper::TicketGrantingTickets

  def process(params = nil, cookies = nil, user_agent = nil)
    params ||= {}
    cookies ||= {}
    ticket_granting_ticket = find_valid_ticket_granting_ticket(cookies[:tgt], user_agent)
    unless ticket_granting_ticket.nil?
      ticket_granting_ticket.destroy
    end
    @listener.user_logged_out(params[:url])
  end
end
