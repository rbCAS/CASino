require 'addressable/uri'

module CASinoCore
  module Helper
    module TicketGrantingTickets
      include CASinoCore::Helper::Browser
      include CASinoCore::Helper::Logger

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
  end
end
