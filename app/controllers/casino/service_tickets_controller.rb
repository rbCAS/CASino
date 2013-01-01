class CASino::ServiceTicketsController < CASino::ApplicationController
  def validate
    processor(:LegacyValidator).process(params)
  end

  def service_validate
    processor(:ServiceTicketValidator, :TicketValidator).process(params)
  end
end
