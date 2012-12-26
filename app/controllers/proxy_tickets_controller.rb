class ProxyTicketsController < ApplicationController
  def proxy_validate
    processor(:ProxyTicketValidator, :TicketValidator).process(params)
  end

  def create
    processor(:ProxyTicketProvider).process(params)
  end
end
