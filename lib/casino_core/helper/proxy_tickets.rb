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

      def validate_ticket_for_service(ticket, service, renew = false)
        result = if service.nil? or ticket.nil?
          logger.warn 'Invalid validate request: no valid ticket or no valid service given'
          'INVALID_REQUEST'
        else
          if ticket.consumed?
            logger.warn "Ticket '#{ticket.ticket}' already consumed"
            'INVALID_TICKET'
          elsif ticket.expired?
            logger.warn "Ticket '#{ticket.ticket}' has expired"
            'INVALID_TICKET'
          elsif clean_service_url(service) != ticket.service
            logger.warn "Ticket '#{ticket.ticket}' is not valid for service '#{service}'"
            'INVALID_SERVICE'
          elsif renew && !ticket.issued_from_credentials?
            logger.info "Ticket '#{ticket.ticket}' was not issued from credentials but service '#{service}' will only accept a renewed ticket"
            'INVALID_TICKET'
          else
            logger.info "Ticket '#{ticket.ticket}' for service '#{service}' successfully validated"
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

      def ticket_valid_for_service?(ticket, service, renew = false)
        validate_ticket_for_service(ticket, service, renew) == true
      end
    end
  end
end
