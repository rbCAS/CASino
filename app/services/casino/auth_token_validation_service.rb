class CASino::AuthTokenValidationService
  include CASino::AuthenticationProcessor

  AUTH_TOKEN_SIGNERS_GLOB = Rails.root.join('config/auth_token_signers/*.pem').freeze

  attr_reader :token, :signature

  def initialize(token, signature)
    @token = token
    @signature = signature
  end

  def validation_result
    return nil unless user_data
    { authenticator: token_data[:authenticator], user_data: user_data }
  end

  def user_data
    return @user_data unless @user_data.nil?
    return nil unless signature_valid?
    return nil unless ticket_valid?
    @user_data = load_user_data(token_data[:authenticator], token_data[:username]).tap do |user|
      if user.nil?
        Rails.logger.warn("Could not load user '#{token_data[:authenticator]}'/'#{token_data[:username]}'")
      else
        Rails.logger.info("User '#{token_data[:authenticator]}'/'#{token_data[:username]}' successfully identified through auth token.")
      end
    end
  end

  def token_data
    begin
      JSON.parse(token).symbolize_keys
    rescue JSON::ParserError
      {}
    end
  end

  private
  def signature_valid?
    Dir.glob(AUTH_TOKEN_SIGNERS_GLOB) do |path|
      if signature_valid_with_key?(path)
        Rails.logger.info("Successfully validated auth token signature with #{File.basename(path)}")
        return true
      end
    end
    Rails.logger.warn('Signature could not be validated: No matching key found.')
    false
  end

  def signature_valid_with_key?(path)
    digest = OpenSSL::Digest::SHA256.new
    key = OpenSSL::PKey::RSA.new(File.read(path))
    key.verify(digest, signature, token)
  end

  def ticket_valid?
    CASino::AuthTokenTicket.consume(token_data[:ticket]).tap do |is_valid|
      Rails.logger.warn('Could not find a valid auth token ticket.') unless is_valid
    end
  end

  def authentication_service
    @authentication_service ||= CASino::AuthenticationService.new
  end
end
