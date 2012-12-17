require 'casino_core/processor'
require 'casino_core/helper'

class CASinoCore::Processor::LoginCredentialRequestor < CASinoCore::Processor
  include CASinoCore::Helper::Browser
  include CASinoCore::Helper::Logger
  include CASinoCore::Helper::LoginTickets
  include CASinoCore::Helper::ServiceTickets
  include CASinoCore::Helper::TicketGrantingTickets

  def process(params = nil, cookies = nil, user_agent = nil)
    params ||= {}
    cookies ||= {}
    request_env ||= {}
    if !params[:renew] && (ticket_granting_ticket = find_valid_ticket_granting_ticket(cookies[:tgt], user_agent))
      service_url_with_ticket = unless params[:service].nil?
        acquire_service_ticket(ticket_granting_ticket, params[:service], true).service_with_ticket_url
      end
      @listener.user_logged_in(service_url_with_ticket)
    else
      login_ticket = acquire_login_ticket
      @listener.user_not_logged_in(login_ticket)
    end
  end
end
