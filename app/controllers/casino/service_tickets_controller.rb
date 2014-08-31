class CASino::ServiceTicketsController < CASino::ApplicationController
  include CASino::ServiceTicketProcessor
  include CASino::ProxyGrantingTicketProcessor
  before_action :load_service_ticket
  before_action :ensure_required_parameters_present, only: [:service_validate]

  def validate
    if ticket_valid_for_service?(@service_ticket, params[:service], renew: params[:renew])
      @username = @service_ticket.ticket_granting_ticket.user.username
    end
    render :validate, formats: [:text]
  end

  def service_validate
    validation_result = validate_ticket_for_service(@service_ticket, params[:service], renew: params[:renew])
    if validation_result.success?
      options = { ticket: @service_ticket }
      options[:proxy_granting_ticket] = acquire_proxy_granting_ticket(params[:pgtUrl], @service_ticket) unless params[:pgtUrl].nil?
      build_service_response(true, options)
    else
      build_service_response(false,
                             error_code: validation_result.error_code,
                             error_message: validation_result.error_message)
    end
  end

  private
  def load_service_ticket
    @service_ticket = CASino::ServiceTicket.where(ticket: params[:ticket]).first if params[:service].present?
  end

  def build_service_response(success, options = {})
    render xml: CASino::TicketValidationResponseBuilder.new(success, options).build
  end

  def ensure_required_parameters_present
    if params[:ticket].nil? || params[:service].nil?
      build_service_response(false,
                             error_code: 'INVALID_REQUEST',
                             error_message: '"ticket" and "service" parameters are both required')
    end
  end
end
