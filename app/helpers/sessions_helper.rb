module SessionsHelper
  def acquire_login_ticket
    ticket = LoginTicket.create ticket: random_ticket_string('LT')
    logger.debug "Created login ticket '#{ticket.ticket}'"
    ticket
  end

  def validate_login_ticket
    login_ticket = params[:lt]
    ticket = LoginTicket.find_by_ticket login_ticket
    valid = if ticket.nil?
      logger.info "Login ticket '#{login_ticket}' not found"
      false
    elsif ticket.created_at < Yetting.login_ticket['lifetime'].seconds.ago
      logger.info "Login ticket '#{ticket.ticket}' expired"
      false
    else
      logger.info "Login ticket '#{ticket.ticket}' successfully validated"
      ticket.delete
      true
    end
    unless valid
      flash[:error] = "No valid login ticket found. Please try again."
      render 'new', status: 403
    end
  end

  def acquire_ticket_granting_ticket(username, extra_attributes = nil)
    TicketGrantingTicket.create!({
      ticket: random_ticket_string('TGC'),
      username: username,
      extra_attributes: extra_attributes,
      user_agent: request.env['HTTP_USER_AGENT']
    })
  end

  def current_user
    nil
  end

  def current_user? user
    @current_user == user
  end

  def signed_in?
    !current_user.nil?
  end

  def validate_login(username, password)
    user_data = nil
    Yetting.authenticators.each do |authenticator|
      instance = "#{authenticator['class']}".constantize.new(authenticator['options'])
      data = instance.validate(username, password)
      if data
        if data[:username].nil?
          data[:username] = username
        end
        user_data = data
        break
      end
    end
    user_data
  end
end
