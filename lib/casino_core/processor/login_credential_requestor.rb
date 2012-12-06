require 'casino_core/processor'
require 'casino_core/helper'

class CASinoCore::Processor::LoginCredentialRequestor < CASinoCore::Processor
  include CASinoCore::Helper

  def process(params = nil, cookies = nil)
    params ||= {}
    cookies ||= {}
    if cookies[:tgt]
      # TODO validate ticket
      # TODO create new service ticket and url
      if params[:service]
        service_url_w_ticket = params[:service] + '?ticket=foo'
      else
        service_url_w_ticket = nil
      end
      @listener.user_logged_in(service_url_w_ticket)
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
end
