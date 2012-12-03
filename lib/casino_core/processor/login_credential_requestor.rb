require 'casino_core/processor'
require 'casino_core/helper'

class CASinoCore::Processor::LoginCredentialRequestor < CASinoCore::Processor
  include CASinoCore::Helper

  def process(params = nil)
    params ||= {}
    login_ticket = acquire_login_ticket
    @listener.render_login_page(login_ticket)
  end

  private
  def acquire_login_ticket
    ticket = CASinoCore::Model::LoginTicket.create ticket: random_ticket_string('LT')
    #logger.debug "Created login ticket '#{ticket.ticket}'"
    ticket
  end
end
