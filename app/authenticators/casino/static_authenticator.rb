require 'casino/authenticator'

# The static authenticator is just a simple example.
# Never ever us this authenticator in a productive environment!
class CASino::StaticAuthenticator < CASino::Authenticator

  # @param [Hash] options
  def initialize(options)
    @users = options[:users] || {}
  end

  def validate(username, password)
    username = :"#{username}"
    if @users.include?(username) && @users[username][:password] == password
      {
        username: "#{username}",
        extra_attributes: @users[username].except(:password)
      }
    else
      false
    end
  end
end
