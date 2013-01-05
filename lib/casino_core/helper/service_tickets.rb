require 'addressable/uri'

module CASinoCore
  module Helper
    module ServiceTickets
      include CASinoCore::Helper::Logger
      include CASinoCore::Helper::Tickets
      include CASinoCore::Helper::ProxyTickets

      class ServiceNotAllowedError < StandardError; end

      def acquire_service_ticket(ticket_granting_ticket, service, credentials_supplied = nil)
        service_url = clean_service_url(service)
        unless CASinoCore::Model::ServiceRule.allowed?(service_url)
          message = "#{service_url} is not in the list of allowed URLs"
          logger.error message
          raise ServiceNotAllowedError, message
        end
        ticket_granting_ticket.service_tickets.create!({
          ticket: random_ticket_string('ST'),
          service: service_url,
          issued_from_credentials: !!credentials_supplied
        })
      end

      def clean_service_url(dirty_service)
        return dirty_service if dirty_service.blank?
        service_uri = Addressable::URI.parse dirty_service
        unless service_uri.query_values.nil?
          service_uri.query_values = service_uri.query_values.except('service', 'ticket', 'gateway', 'renew')
        end
        if service_uri.query_values.blank?
          service_uri.query_values = nil
        end
        if "#{service_uri.path}".length > 1
          service_uri.path = service_uri.path.gsub(/\/\z/, '')
        end
        clean_service = service_uri.to_s

        logger.debug("Cleaned dirty service URL '#{dirty_service}' to '#{clean_service}'") if dirty_service != clean_service

        clean_service
      end
    end
  end
end
