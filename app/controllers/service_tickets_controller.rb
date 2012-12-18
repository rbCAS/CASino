class ServiceTicketsController < ApplicationController
  def validate
    processor(:LegacyValidator).process(params)
  end
end
