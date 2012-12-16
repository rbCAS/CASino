module CASino
  class Listener
    autoload :LoginCredentialAcceptor, 'casino/listener/login_credential_acceptor.rb'
    autoload :LoginCredentialRequestor, 'casino/listener/login_credential_requestor.rb'

    def initialize(controller)
      @controller = controller
    end

    protected
    def assign(name, value)
      @controller.instance_variable_set("@#{name}", value)
    end
  end
end
