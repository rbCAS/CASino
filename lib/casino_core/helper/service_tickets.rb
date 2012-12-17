require 'addressable/uri'

module CASinoCore
  module Helper
    module ServiceTickets
      include CASinoCore::Helper::Logger
      include CASinoCore::Helper::Tickets

      def acquire_service_ticket(ticket_granting_ticket, service, credentials_supplied = nil)
        ticket_granting_ticket.service_tickets.create!({
          ticket: random_ticket_string('ST'),
          service: clean_service_url(service),
          issued_from_credentials: !!credentials_supplied
        })
      end

      def clean_service_url(dirty_service)
        return dirty_service if dirty_service.blank?
        service_uri = Addressable::URI.parse dirty_service
        unless service_uri.query_values.nil?
          service_uri.query_values = service_uri.query_values.except('service', 'ticket', 'gateway', 'renew')
        end
        clean_service = service_uri.to_s

        logger.debug("Cleaned dirty service URL '#{dirty_service}' to '#{clean_service}'") if dirty_service != clean_service

        clean_service
      end
    end
  end
end
