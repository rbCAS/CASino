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

      def validate_service_ticket_for_service(ticket, service, renew = false)
        result = if service.nil? or ticket.nil?
          logger.warn 'Invalid validate request: no valid ticket or no valid service given'
          'INVALID_REQUEST'
        else
          if ticket.consumed?
            logger.warn "Service ticket '#{ticket.ticket}' already consumed"
            'INVALID_TICKET'
          elsif Time.now - ticket.created_at > CASinoCore::Settings.service_ticket[:lifetime_unconsumed]
            logger.warn "Service ticket '#{ticket.ticket}' has expired"
            'INVALID_TICKET'
          elsif clean_service_url(service) != ticket.service
            logger.warn "Service ticket '#{ticket.ticket}' is not valid for service '#{service}'"
            'INVALID_SERVICE'
          elsif renew && !ticket.issued_from_credentials?
            logger.info "Service ticket '#{ticket.ticket}' was not issued from credentials but service '#{service}' will only accept a renewed ticket"
            'INVALID_TICKET'
          else
            logger.info "Service ticket '#{ticket.ticket}' for service '#{service}' successfully validated"
            true
          end
        end
        unless ticket.nil?
          logger.debug "Consumed ticket '#{ticket.ticket}'"
          ticket.consumed = true
          ticket.save!
        end
        result
      end

      def service_ticket_valid_for_service?(ticket, service, renew = false)
        validate_service_ticket_for_service(ticket, service, renew) == true
      end
    end
  end
end
