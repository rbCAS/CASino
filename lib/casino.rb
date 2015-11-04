require 'active_support/configurable'
require 'casino/engine'

module CASino
  include ActiveSupport::Configurable

  defaults = {
    authenticators: HashWithIndifferentAccess.new,
    require_service_rules: false,
    logger: Rails.logger,
    frontend: HashWithIndifferentAccess.new(
      sso_name: 'CASino',
      footer_text: 'Powered by <a href="http://rbcas.com/">CASino</a>'
    ),
    implementors: HashWithIndifferentAccess.new(
      login_ticket: nil,
      proxy_granting_ticket: nil,
      proxy_ticket: nil,
      service_rule: nil,
      service_ticket: nil,
      ticket_granting_ticket: nil,
      two_factor_authenticator: nil,
      user: nil
    ),
    auth_token_ticket: {
      lifetime: 60
    },
    login_ticket: {
      lifetime: 600
    },
    ticket_granting_ticket: {
      lifetime: 86400,
      lifetime_long_term: 864000
    },
    service_ticket: {
      lifetime_unconsumed: 300,
      lifetime_consumed: 86400,
      single_sign_out_notification: {
        timeout: 5
      }
    },
    proxy_ticket: {
      lifetime_unconsumed: 300,
      lifetime_consumed: 86400
    },
    two_factor_authenticator: {
      timeout: 180,
      lifetime_inactive: 300,
      drift: 30
    }
  }

  self.config.merge! defaults.deep_dup
end
