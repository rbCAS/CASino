module CASino
  class Listener

    # include helpers to have the route path methods (like sessions_path)
    include Rails.application.routes.url_helpers

    autoload :LegacyValidator, 'casino/listener/legacy_validator.rb'
    autoload :LoginCredentialAcceptor, 'casino/listener/login_credential_acceptor.rb'
    autoload :LoginCredentialRequestor, 'casino/listener/login_credential_requestor.rb'
    autoload :Logout, 'casino/listener/logout.rb'
    autoload :ProxyTicketProvider, 'casino/listener/proxy_ticket_provider.rb'
    autoload :SessionDestroyer, 'casino/listener/session_destroyer.rb'
    autoload :SessionOverview, 'casino/listener/session_overview.rb'
    autoload :TicketValidator, 'casino/listener/ticket_validator.rb'

    def initialize(controller)
      @controller = controller
    end

    protected
    def assign(name, value)
      @controller.instance_variable_set("@#{name}", value)
    end
  end
end
