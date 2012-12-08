module CASinoCore
  module Helper
    module ServiceTickets
      include CASinoCore::Helper

      def acquire_service_ticket(ticket_granting_ticket, service, credentials_supplied = nil)
        ticket_granting_ticket.service_tickets.create!({
          ticket: random_ticket_string('ST'),
          service: clean_service_url(service),
          issued_from_credentials: !!credentials_supplied
        })
      end

      def clean_service_url(dirty_service)
        return dirty_service if dirty_service.blank?
        clean_service = dirty_service.dup
        ['service', 'ticket', 'gateway', 'renew'].each do |p|
          clean_service.sub!(Regexp.new("&?#{p}=[^&]*"), '')
        end

        clean_service = clean_service.gsub(/[\/\?&]$/, '').gsub('?&', '?').gsub(' ', '+')

        logger.debug("Cleaned dirty service URL '#{dirty_service}' to '#{clean_service}'") if dirty_service != clean_service

        clean_service
      end
    end
  end
end
