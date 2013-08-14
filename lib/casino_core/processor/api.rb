module CASinoCore
  class Processor
    module API
      autoload :LoginCredentialAcceptor, 'casino_core/processor/api/login_credential_acceptor.rb'
      autoload :ServiceTicketProvider, 'casino_core/processor/api/service_ticket_provider.rb'
      autoload :Logout, 'casino_core/processor/api/logout.rb'
    end
  end
end
