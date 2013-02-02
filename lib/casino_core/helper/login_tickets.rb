module CASinoCore
  module Helper
    module LoginTickets
      include CASinoCore::Helper::Logger
      include CASinoCore::Helper::Tickets

      def acquire_login_ticket
        ticket = CASinoCore::Model::LoginTicket.create ticket: random_ticket_string('LT')
        logger.debug "Created login ticket '#{ticket.ticket}'"
        ticket
      end

      def login_ticket_valid?(lt)
        ticket = CASinoCore::Model::LoginTicket.find_by_ticket lt
        if ticket.nil?
          logger.info "Login ticket '#{lt}' not found"
          false
        elsif ticket.created_at < CASinoCore::Settings.login_ticket[:lifetime].seconds.ago
          logger.info "Login ticket '#{ticket.ticket}' expired"
          false
        else
          logger.debug "Login ticket '#{ticket.ticket}' successfully validated"
          ticket.delete
          true
        end
      end
    end
  end
end
