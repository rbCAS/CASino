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
    end
  end
end
