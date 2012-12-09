require 'active_record'

module CASinoCore
  class Processor
    autoload :LegacyValidator, 'casino_core/processor/legacy_validator.rb'
    autoload :LoginCredentialAcceptor, 'casino_core/processor/login_credential_acceptor.rb'
    autoload :LoginCredentialRequestor, 'casino_core/processor/login_credential_requestor.rb'
    autoload :SessionDestroyer, 'casino_core/processor/session_destroyer.rb'

    def initialize(listener)
      @listener = listener
    end
  end
end
