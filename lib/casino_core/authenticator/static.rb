require 'casino_core/authenticator'

class CASinoCore::Authenticator::Static < CASinoCore::Authenticator
  def initialize(options)
    @users = options['users'] || {}
  end

  def validate(username, password)
    if @users.include?(username) && @users[username]['password'] == password
      {
        username: username,
        extra_attributes: @users[username].delete_if { |key, value| key == 'password' }
      }
    else
      false
    end
  end
end
