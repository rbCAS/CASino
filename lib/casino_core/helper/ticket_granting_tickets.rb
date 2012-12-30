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

      def acquire_ticket_granting_ticket(authentication_result, user_agent = nil)
        user_data = authentication_result[:user_data]
        CASinoCore::Model::TicketGrantingTicket.create!({
          ticket: random_ticket_string('TGC'),
          authenticator: authentication_result[:authenticator],
          username: user_data[:username],
          extra_attributes: user_data[:extra_attributes],
          user_agent: user_agent
        })
      end

      def remove_ticket_granting_ticket(ticket_granting_ticket, user_agent = nil)
        tgt = find_valid_ticket_granting_ticket(ticket_granting_ticket, user_agent)
        tgt.destroy rescue false
      end

    end
  end
end
