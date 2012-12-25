module CASinoCore
  module Helper
    module ProxyTickets
      include CASinoCore::Helper::Logger
      include CASinoCore::Helper::Tickets

      def acquire_proxy_ticket(proxy_granting_ticket, service)
        proxy_granting_ticket.proxy_tickets.create!({
          ticket: random_ticket_string('ST'),
          service: service,
        })
      end
    end
  end
end
