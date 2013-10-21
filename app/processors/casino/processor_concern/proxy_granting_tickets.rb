require 'addressable/uri'
require 'faraday'

module CASino
  module ProcessorConcern
    module ProxyGrantingTickets
      include CASino::ProcessorConcern::Tickets

      def acquire_proxy_granting_ticket(pgt_url, service_ticket)
        callback_uri = Addressable::URI.parse(pgt_url)
        if callback_uri.scheme != 'https'
          Rails.logger.warn "Proxy tickets can only be granted to callback servers using HTTPS."
          nil
        else
          contact_callback_server(callback_uri, service_ticket)
        end
      end

      private
      def contact_callback_server(callback_uri, service_ticket)
        pgt = service_ticket.proxy_granting_tickets.new({
          ticket: random_ticket_string('PGT'),
          iou: random_ticket_string('PGTIOU'),
          pgt_url: "#{callback_uri}"
        })
        callback_uri.query_values = (callback_uri.query_values || {}).merge(pgtId: pgt.ticket, pgtIou: pgt.iou)
        response = Faraday.get "#{callback_uri}"
        # TODO: does this follow redirects? CAS specification says that redirects MAY be followed (2.5.4)
        if response.success?
          pgt.save!
          Rails.logger.debug "Proxy-granting ticket generated for service '#{service_ticket.service}': #{pgt.inspect}"
          pgt
        else
          Rails.logger.warn "Proxy-granting ticket callback server responded with a bad result code '#{response.status}'. PGT will not be stored."
          nil
        end
      rescue Faraday::Error::ClientError => error
        Rails.logger.warn "Exception while communicating with proxy-granting ticket callback server: #{error.message}"
        nil
      end
    end
  end
end
