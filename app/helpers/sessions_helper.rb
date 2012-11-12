module SessionsHelper
  def acquire_login_ticket
    ticket = false
    while !ticket
      ticket = LoginTicket.create ticket: 'LT-' + SecureRandom.urlsafe_base64(30)
    end
    ticket
  end

  def validate_login_ticket
    ticket = LoginTicket.find_by_ticket (params[:session] || {})[:login_ticket]
    valid = if ticket.nil?
      logger.info "No login ticket found"
      false
    elsif ticket.created_at < 2.hours.ago
      logger.info "Login ticket expired"
      false
    else
      ticket.delete
      true
    end
    unless valid
      flash[:error] = "No valid login ticket found. Please try again."
      redirect_to login_path
    end
  end
end
