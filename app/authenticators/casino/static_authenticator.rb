require 'casino/authenticator'

# The static authenticator is just a simple example.
# Never use this authenticator in a productive environment!
class CASino::StaticAuthenticator < CASino::Authenticator

  # @param [Hash] options
  def initialize(options)
    @users = options[:users] || {}
  end

  def validate(username, password)
    username = :"#{username}"
    if @users.include?(username) && @users[username][:password] == password
      load_user_data(username)
    else
      false
    end
  end

  def load_user_data(username)
    if @users.include?(username)
      {
        username: "#{username}",
        extra_attributes: @users[username].except(:password)
      }
    end
  end
end
