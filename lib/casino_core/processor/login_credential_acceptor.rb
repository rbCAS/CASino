require 'casino_core/processor'
require 'casino_core/helper'

class CASinoCore::Processor::LoginCredentialAcceptor < CASinoCore::Processor
  include CASinoCore::Helper

  def process(params = nil)
    params ||= {}
    if login_ticket_valid?(params[:lt])
      user_data = validate_login_credentials(params[:username], params[:password])
      if !user_data.nil?
        if params[:service].blank?
          @listener.user_logged_in_without_service
        else
          @listener.redirect_to(params[:service])
        end
      else
        @listener.invalid_login_credentials
      end
    else
      @listener.invalid_login_ticket
    end
  end

  private
  def login_ticket_valid?(lt)
    ticket = CASinoCore::Model::LoginTicket.find_by_ticket lt
    if ticket.nil?
      logger.info "Login ticket '#{lt}' not found"
      false
    elsif ticket.created_at < CASinoCore::Settings.login_ticket[:lifetime].seconds.ago
      logger.info "Login ticket '#{ticket.ticket}' expired"
      false
    else
      logger.debug "Login ticket '#{ticket.ticket}' successfully validated"
      ticket.delete
      true
    end
  end

  def validate_login_credentials(username, password)
    user_data = nil
    CASinoCore::Settings.authenticators.each do |authenticator|
      instance = authenticator[:class].constantize.new(authenticator[:options])
      data = instance.validate(username, password)
      if data
        if data[:username].nil?
          data[:username] = username
        end
        user_data = data
        logger.info("Credentials for username '#{data[:username]}' successfully validated using #{authenticator['class']}")
        break
      end
    end
    user_data
  end
end
