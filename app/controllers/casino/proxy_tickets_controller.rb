class CASino::ProxyTicketsController < CASino::ApplicationController
  include CASino::ControllerConcern::TicketValidator

  before_action :load_ticket, only: [:proxy_validate]
  before_action :ensure_required_parameters_present, only: [:proxy_validate]

  def proxy_validate
    validate_ticket(@ticket)
  end

  def create
    processor(:ProxyTicketProvider).process(params)
  end

  private
  def load_ticket
    @ticket = case params[:ticket]
              when /\APT-/
                CASino::ProxyTicket.where(ticket: params[:ticket]).first
              when /\AST-/
                CASino::ServiceTicket.where(ticket: params[:ticket]).first
              end
  end
end
