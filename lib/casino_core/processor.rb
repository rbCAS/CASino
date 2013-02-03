require 'active_record'

module CASinoCore
  class Processor
    autoload :LegacyValidator, 'casino_core/processor/legacy_validator.rb'
    autoload :LoginCredentialAcceptor, 'casino_core/processor/login_credential_acceptor.rb'
    autoload :LoginCredentialRequestor, 'casino_core/processor/login_credential_requestor.rb'
    autoload :Logout, 'casino_core/processor/logout.rb'
    autoload :ProxyTicketProvider, 'casino_core/processor/proxy_ticket_provider.rb'
    autoload :ProxyTicketValidator, 'casino_core/processor/proxy_ticket_validator.rb'
    autoload :ServiceTicketValidator, 'casino_core/processor/service_ticket_validator.rb'
    autoload :SessionDestroyer, 'casino_core/processor/session_destroyer.rb'
    autoload :SessionOverview, 'casino_core/processor/session_overview.rb'
    autoload :TwoFactorAuthenticatorOverview, 'casino_core/processor/two_factor_authenticator_overview.rb'
    autoload :TwoFactorAuthenticatorProvider, 'casino_core/processor/two_factor_authenticator_provider.rb'

    autoload :API, 'casino_core/processor/api.rb'

    def initialize(listener)
      @listener = listener
    end
  end
end
