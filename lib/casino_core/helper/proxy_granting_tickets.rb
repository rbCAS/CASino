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
          uri = URI.parse(pgt_url)
          https = Net::HTTP.new(uri.host, uri.port)
          https.use_ssl = true

          https.start do |conn|
            pgt = service_ticket.proxy_granting_ticket.new({
              ticket: random_ticket_string('PGT'),
              iou: random_ticket_string('PGTIOU')
            })

            uri.query_values = (uri.query_values || {}).merge(pgtId: pgt.ticket, pgtIou: pgt.iou)

            response = conn.request_get(uri.request_uri)
            # TODO: follow redirects... 2.5.4 says that redirects MAY be followed
            if response.code == 200
              # 3.4 (proxy-granting ticket IOU)
              pgt.save!
              logger.debug "Proxy-granting ticket generated for pgt_url '#{pgt_url}': #{pgt.inspect}"
              return pgt
            else
              logger.warn "Proxy-granting ticket callback server responded with a bad result code '#{response.code}'. PGT will not be stored."
            end
          end
        rescue Exception => e
          logger.warn "Exception while communication with proxy-granting ticket callback server: #{e.message}"
        end
        nil
      end
    end
  end
end
