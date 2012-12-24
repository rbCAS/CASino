class ServiceTicketsController < ApplicationController
  def validate
    processor(:LegacyValidator).process(params)
  end

  def service_validate
    processor(:ServiceTicketValidator).process(params)
  end
end
