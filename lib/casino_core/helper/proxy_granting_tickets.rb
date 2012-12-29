require 'addressable/uri'
require 'net/https'

require 'casino_core/helper/logger'
require 'casino_core/helper/tickets'

module CASinoCore
  module Helper
    module ProxyGrantingTickets
      include CASinoCore::Helper::Logger
      include CASinoCore::Helper::Tickets

      def acquire_proxy_granting_ticket(pgt_url, service_ticket)
        begin
          return contact_callback_server(pgt_url, service_ticket)
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
          logger.warn "Exception while communicating with proxy-granting ticket callback server: #{e.message}"
        end
        nil
      end

      private
      def contact_callback_server(pgt_url, service_ticket)
        callback_uri = Addressable::URI.parse(pgt_url)
        https = Net::HTTP.new(callback_uri.host, callback_uri.port || 443)
        https.use_ssl = true

        https.start do |conn|
          pgt = service_ticket.proxy_granting_tickets.new({
            ticket: random_ticket_string('PGT'),
            iou: random_ticket_string('PGTIOU'),
            pgt_url: pgt_url
          })

          callback_uri.query_values = (callback_uri.query_values || {}).merge(pgtId: pgt.ticket, pgtIou: pgt.iou)

          response = conn.request_get(callback_uri.request_uri)
          # TODO: follow redirects... 2.5.4 says that redirects MAY be followed
          if "#{response.code}" == "200"
            # 3.4 (proxy-granting ticket IOU)
            pgt.save!
            logger.debug "Proxy-granting ticket generated for service '#{service_ticket.service}': #{pgt.inspect}"
            pgt
          else
            logger.warn "Proxy-granting ticket callback server responded with a bad result code '#{response.code}'. PGT will not be stored."
            nil
          end
        end
      end
    end
  end
end
