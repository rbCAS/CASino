require 'casino_core/processor'
require 'casino_core/helper'
require 'casino_core/model'

class CASinoCore::Processor::SessionDestroyer < CASinoCore::Processor
  include CASinoCore::Helper

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
