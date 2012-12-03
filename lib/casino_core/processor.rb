require 'active_record'

module CASinoCore
  class Processor
    autoload :LoginCredentialRequestor, 'casino_core/processor/login_credential_requestor.rb'
    autoload :LoginCredentialAcceptor, 'casino_core/processor/login_credential_acceptor.rb'

    def initialize(listener)
      @listener = listener
    end
  end
end
