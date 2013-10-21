require 'addressable/uri'

module CASino
  module ProcessorConcern
    module ServiceTickets
      include CASino::ProcessorConcern::Tickets
      include CASino::ProcessorConcern::ProxyTickets

      class ServiceNotAllowedError < StandardError; end

      RESERVED_CAS_PARAMETER_KEYS = ['service', 'ticket', 'gateway', 'renew']

      def acquire_service_ticket(ticket_granting_ticket, service, credentials_supplied = nil)
        service_url = clean_service_url(service)
        unless CASino::ServiceRule.allowed?(service_url)
          message = "#{service_url} is not in the list of allowed URLs"
          Rails.logger.error message
          raise ServiceNotAllowedError, message
        end
        service_tickets = ticket_granting_ticket.service_tickets
        service_tickets.where(service: service_url).destroy_all
        service_tickets.create!({
          ticket: random_ticket_string('ST'),
          service: service_url,
          issued_from_credentials: !!credentials_supplied
        })
      end

      def clean_service_url(dirty_service)
        return dirty_service if dirty_service.blank?
        service_uri = Addressable::URI.parse dirty_service
        unless service_uri.query_values.nil?
          service_uri.query_values = service_uri.query_values(Array).select { |k,v| !RESERVED_CAS_PARAMETER_KEYS.include?(k) }
        end
        if service_uri.query_values.blank?
          service_uri.query_values = nil
        end

        service_uri.path = (service_uri.path || '').gsub(/\/+\z/, '')
        service_uri.path = '/' if service_uri.path.blank?

        clean_service = service_uri.to_s

        Rails.logger.debug("Cleaned dirty service URL '#{dirty_service}' to '#{clean_service}'") if dirty_service != clean_service

        clean_service
      end
    end
  end
end
