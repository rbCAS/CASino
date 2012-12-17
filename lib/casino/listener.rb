module CASino
  class Listener

    # include helpers to have the route path methods (like sessions_path)
    include Rails.application.routes.url_helpers

    autoload :LoginCredentialAcceptor, 'casino/listener/login_credential_acceptor.rb'
    autoload :LoginCredentialRequestor, 'casino/listener/login_credential_requestor.rb'
    autoload :Logout, 'casino/listener/logout.rb'

    def initialize(controller)
      @controller = controller
    end

    protected
    def assign(name, value)
      @controller.instance_variable_set("@#{name}", value)
    end
  end
end
