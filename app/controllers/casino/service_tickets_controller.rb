class CASino::ServiceTicketsController < CASino::ApplicationController
  include CASino::ControllerConcern::TicketValidator

  before_action :load_service_ticket
  before_action :ensure_service_ticket_parameters_present, only: [:service_validate]

  def validate
    if ticket_valid_for_service?(@service_ticket, params[:service], renew: params[:renew])
      @username = @service_ticket.ticket_granting_ticket.user.username
    end
    render :validate, formats: [:text]
  end

  def service_validate
    validate_ticket(@service_ticket)
  end

  private
  def load_service_ticket
    @service_ticket = CASino::ServiceTicket.where(ticket: params[:ticket]).first if params[:service].present?
  end
end
