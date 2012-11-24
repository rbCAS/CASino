require 'casino/authenticator/base'

class CASino::Authenticator::Static < CASino::Authenticator::Base
  def initialize(options)
    @users = options['users'] || {}
  end

  def validate(username, password)
    if @users.include?(username) && @users[username]['password'] == password
      {
        username: username,
        extra_attributes: @users[username].except('password')
      }
    else
      false
    end
  end
end
