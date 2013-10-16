require 'addressable/uri'

module CASino
  module ProcessorConcern
    module TicketGrantingTickets

      include CASino::ProcessorConcern::Browser

      def find_valid_ticket_granting_ticket(tgt, user_agent, ignore_two_factor = false)
        ticket_granting_ticket = CASino::TicketGrantingTicket.where(ticket: tgt).first
        unless ticket_granting_ticket.nil?
          if ticket_granting_ticket.expired?
            Rails.logger.info "Ticket-granting ticket expired (Created: #{ticket_granting_ticket.created_at})"
            ticket_granting_ticket.destroy
            nil
          elsif !ignore_two_factor && ticket_granting_ticket.awaiting_two_factor_authentication?
            Rails.logger.info 'Ticket-granting ticket is valid, but two-factor authentication is pending'
            nil
          elsif same_browser?(ticket_granting_ticket.user_agent, user_agent)
            ticket_granting_ticket.user_agent = user_agent
            ticket_granting_ticket.touch
            ticket_granting_ticket.save!
            ticket_granting_ticket
          else
            Rails.logger.info 'User-Agent changed: ticket-granting ticket not valid for this browser'
            nil
          end
        end
      end

      def acquire_ticket_granting_ticket(authentication_result, user_agent = nil, long_term = nil)
        user_data = authentication_result[:user_data]
        user = load_or_initialize_user(authentication_result[:authenticator], user_data[:username], user_data[:extra_attributes])
        cleanup_expired_ticket_granting_tickets(user)
        user.ticket_granting_tickets.create!({
          ticket: random_ticket_string('TGC'),
          awaiting_two_factor_authentication: !user.active_two_factor_authenticator.nil?,
          user_agent: user_agent,
          long_term: !!long_term
        })
      end

      def load_or_initialize_user(authenticator, username, extra_attributes)
        user = CASino::User.where(
          authenticator: authenticator,
          username: username).first_or_initialize
        user.extra_attributes = extra_attributes
        user.save!
        return user
      end

      def remove_ticket_granting_ticket(ticket_granting_ticket, user_agent = nil)
        tgt = find_valid_ticket_granting_ticket(ticket_granting_ticket, user_agent)
        unless tgt.nil?
          tgt.destroy
        end
      end

      def cleanup_expired_ticket_granting_tickets(user)
        CASino::TicketGrantingTicket.cleanup(user)
      end

    end
  end
end
