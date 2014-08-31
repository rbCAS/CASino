class CASino::ServiceTicketsController < CASino::ApplicationController
  include CASino::ServiceTicketProcessor
  before_action :load_service_ticket

  def validate
    if ticket_valid_for_service?(@service_ticket, params[:service], renew: params[:renew])
      @username = @service_ticket.ticket_granting_ticket.user.username
    end
    render :validate, formats: [:text]
  end

  def service_validate
    processor(:ServiceTicketValidator, :TicketValidator).process(params)
  end

  private
  def load_service_ticket
    @service_ticket = CASino::ServiceTicket.where(ticket: params[:ticket]).first if params[:service].present?
  end
end
