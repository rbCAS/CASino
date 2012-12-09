require 'casino_core/processor'
require 'casino_core/helper'

class CASinoCore::Processor::LoginCredentialRequestor < CASinoCore::Processor
  include CASinoCore::Helper
  include CASinoCore::Helper::ServiceTickets
  include CASinoCore::Helper::Browser

  def process(params = nil, cookies = nil, user_agent = nil)
    params ||= {}
    cookies ||= {}
    request_env ||= {}
    if !params[:renew] && (ticket_granting_ticket = find_valid_ticket_granting_ticket(cookies[:tgt], user_agent))
      # TODO create new service ticket and url
      service_url_with_ticket = unless params[:service].nil?
        acquire_service_ticket(ticket_granting_ticket, params[:service], true).service_with_ticket_url
      end
      @listener.user_logged_in(service_url_with_ticket)
    else
      login_ticket = acquire_login_ticket
      @listener.user_not_logged_in(login_ticket)
    end
  end

  private
  def acquire_login_ticket
    ticket = CASinoCore::Model::LoginTicket.create ticket: random_ticket_string('LT')
    logger.debug "Created login ticket '#{ticket.ticket}'"
    ticket
  end

  def find_valid_ticket_granting_ticket(tgt, user_agent)
    ticket_granting_ticket = CASinoCore::Model::TicketGrantingTicket.where(ticket: tgt).first
    unless ticket_granting_ticket.nil?
      if same_browser?(ticket_granting_ticket.user_agent, user_agent)
        ticket_granting_ticket.user_agent = user_agent
        ticket_granting_ticket.save!
        ticket_granting_ticket
      else
        logger.info 'User-Agent changed: ticket-granting ticket not valid for this browser'
        nil
      end
    end
  end
end
