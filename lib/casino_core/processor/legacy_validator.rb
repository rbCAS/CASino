require 'casino_core/processor'
require 'casino_core/helper'
require 'casino_core/model'

# The LegacyValidator processor should be used for GET requests to /validate
class CASinoCore::Processor::LegacyValidator < CASinoCore::Processor
  include CASinoCore::Helper::Logger
  include CASinoCore::Helper::ServiceTickets

  # This method will call `#validation_succeeded` or `#validation_failed`. In both cases, it supplies
  # a string as argument. The webapplication should present that string (and nothing else) to the
  # requestor.
  #
  # @param [Hash] params parameters supplied by requestor (a service)
  def process(params = nil)
    params ||= {}
    ticket = CASinoCore::Model::ServiceTicket.where(ticket: params[:ticket]).first
    if ticket_valid_for_service?(ticket, params[:service], !!params[:renew])
      @listener.validation_succeeded("yes\n#{ticket.ticket_granting_ticket.username}\n")
    else
      @listener.validation_failed("no\n\n")
    end
  end

  private
  def ticket_valid_for_service?(ticket, service, renew = false)
    ticket_valid = if service.nil? or ticket.nil?
      logger.warn 'Invalid validate request: no valid ticket or no valid service given'
      false
    else
      if ticket.consumed?
        logger.warn "Service ticket '#{ticket.ticket}' already consumed"
        false
      elsif Time.now - ticket.created_at > CASinoCore::Settings.service_ticket[:lifetime_unconsumed]
        logger.warn "Service ticket '#{ticket.ticket}' has expired"
        false
      elsif clean_service_url(service) != ticket.service
        logger.warn "Service ticket '#{ticket.ticket}' is not valid for service '#{service}'"
        false
      elsif renew && !ticket.issued_from_credentials?
        logger.info "Service ticket '#{ticket.ticket}' was not issued from credentials but service '#{service}' will only accept a renewed ticket"
        false
      else
        logger.info "Service ticket '#{ticket.ticket}' for service '#{service}' successfully validated"
        true
      end
    end
    unless ticket.nil?
      logger.debug "Consumed ticket '#{ticket.ticket}'"
      ticket.consumed = true
      ticket.save!
    end
    ticket_valid
  end
end
