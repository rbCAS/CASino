class ServiceTicketsController < ApplicationController
  def validate
    ticket = ServiceTicket.where(ticket: params[:ticket]).first
    if ticket_valid_for_service?(ticket, params[:service], !!params[:renew])
      @username = ticket.ticket_granting_ticket.username
    end
    render 'validate', formats: [:text]
  end

  private
  def ticket_valid_for_service?(ticket, service, renew = false)
    ticket_valid = if service.nil? or ticket.nil?
      Rails.logger.warn 'Invalid validate request: no valid ticket or no valid service given'
      false
    else
      if ticket.consumed?
        Rails.logger.warn "Service ticket '#{ticket.ticket}' already consumed"
        false
      elsif Time.now - ticket.created_at > Yetting.service_ticket['lifetime_unconsumed']
        Rails.logger.warn "Service ticket '#{ticket.ticket}' has expired"
        false
      elsif clean_service_url(service) != ticket.service
        Rails.logger.warn "Service ticket '#{ticket.ticket}' is not valid for service '#{service}'"
        false
      else
        Rails.logger.info "Service ticket '#{ticket.ticket}' for service '#{service}' successfully validated"
        true
      end
      # TODO handle renew
    end
    unless ticket.nil?
      ticket.consumed = true
      ticket.save!
    end
    ticket_valid
  end
end
