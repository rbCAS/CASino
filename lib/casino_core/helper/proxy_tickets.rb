module CASinoCore
  module Helper
    module ProxyTickets

      class ValidationResult < Struct.new(:error_code, :error_message, :error_severity)
        def success?
          self.error_code.nil?
        end
      end

      include CASinoCore::Helper::Logger
      include CASinoCore::Helper::Tickets

      def acquire_proxy_ticket(proxy_granting_ticket, service)
        proxy_granting_ticket.proxy_tickets.create!({
          ticket: random_ticket_string('ST'),
          service: service,
        })
      end

      def validate_ticket_for_service(ticket, service, renew = false)
        if ticket.nil?
          result = ValidationResult.new 'INVALID_TICKET', 'Invalid validate request: Ticket does not exist', :warn
        else
          result = validate_existing_ticket_for_service(ticket, service, renew)
          ticket.consumed = true
          ticket.save!
          logger.debug "Consumed ticket '#{ticket.ticket}'"
        end
        if result.success?
          logger.info "Ticket '#{ticket.ticket}' for service '#{service}' successfully validated"
        else
          logger.send(result.error_severity, result.error_message)
        end
        result
      end

      def ticket_valid_for_service?(ticket, service, renew = false)
        validate_ticket_for_service(ticket, service, renew).success?
      end

      private
      def validate_existing_ticket_for_service(ticket, service, renew = false)
        if ticket.consumed?
          ValidationResult.new 'INVALID_TICKET', "Ticket '#{ticket.ticket}' already consumed", :warn
        elsif ticket.expired?
          ValidationResult.new 'INVALID_TICKET', "Ticket '#{ticket.ticket}' has expired", :warn
        elsif clean_service_url(service) != ticket.service
          ValidationResult.new 'INVALID_SERVICE', "Ticket '#{ticket.ticket}' is not valid for service '#{service}'", :warn
        elsif renew && !ticket.issued_from_credentials?
          ValidationResult.new 'INVALID_TICKET', "Ticket '#{ticket.ticket}' was not issued from credentials but service '#{service}' will only accept a renewed ticket", :info
        else
          ValidationResult.new
        end
      end
    end
  end
end
