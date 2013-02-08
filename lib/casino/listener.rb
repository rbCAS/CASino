module CASino
  class Listener

    # include helpers to have the route path methods (like sessions_path)
    include CASino::Engine.routes.url_helpers

    autoload :LegacyValidator, 'casino/listener/legacy_validator.rb'
    autoload :LoginCredentialAcceptor, 'casino/listener/login_credential_acceptor.rb'
    autoload :LoginCredentialRequestor, 'casino/listener/login_credential_requestor.rb'
    autoload :Logout, 'casino/listener/logout.rb'
    autoload :ProxyTicketProvider, 'casino/listener/proxy_ticket_provider.rb'
    autoload :SecondFactorAuthenticationAcceptor, 'casino/listener/second_factor_authentication_acceptor.rb'
    autoload :SessionDestroyer, 'casino/listener/session_destroyer.rb'
    autoload :SessionOverview, 'casino/listener/session_overview.rb'
    autoload :TicketValidator, 'casino/listener/ticket_validator.rb'
    autoload :TwoFactorAuthenticatorActivator, 'casino/listener/two_factor_authenticator_activator.rb'
    autoload :TwoFactorAuthenticatorDestroyer, 'casino/listener/two_factor_authenticator_destroyer.rb'
    autoload :TwoFactorAuthenticatorOverview, 'casino/listener/two_factor_authenticator_overview.rb'
    autoload :TwoFactorAuthenticatorRegistrator, 'casino/listener/two_factor_authenticator_registrator.rb'

    def initialize(controller)
      @controller = controller
    end

    protected
    def assign(name, value)
      @controller.instance_variable_set("@#{name}", value)
    end
  end
end
