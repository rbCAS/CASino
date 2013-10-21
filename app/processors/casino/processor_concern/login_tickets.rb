module CASino
  module ProcessorConcern
    module LoginTickets
      include CASino::ProcessorConcern::Tickets

      def acquire_login_ticket
        ticket = CASino::LoginTicket.create ticket: random_ticket_string('LT')
        Rails.logger.debug "Created login ticket '#{ticket.ticket}'"
        ticket
      end

      def login_ticket_valid?(lt)
        ticket = CASino::LoginTicket.find_by_ticket lt
        if ticket.nil?
          Rails.logger.info "Login ticket '#{lt}' not found"
          false
        elsif ticket.created_at < CASino.config.login_ticket[:lifetime].seconds.ago
          Rails.logger.info "Login ticket '#{ticket.ticket}' expired"
          false
        else
          Rails.logger.debug "Login ticket '#{ticket.ticket}' successfully validated"
          ticket.delete
          true
        end
      end
    end
  end
end
