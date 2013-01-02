class CASino::ProxyTicketsController < CASino::ApplicationController
  def proxy_validate
    processor(:ProxyTicketValidator, :TicketValidator).process(params)
  end

  def create
    processor(:ProxyTicketProvider).process(params)
  end
end
