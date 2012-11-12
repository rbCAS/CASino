module SessionsHelper
  def acquire_login_ticket
    ticket = false
    while !ticket
      ticket = LoginTicket.create ticket: 'LT-' + SecureRandom.urlsafe_base64(30)
    end
    ticket
  end
end
