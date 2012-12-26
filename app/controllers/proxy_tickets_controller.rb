class ProxyTicketsController < ApplicationController
  def proxy_validate
    processor(:ProxyTicketValidator, :TicketValidator).process(params)
  end
end
