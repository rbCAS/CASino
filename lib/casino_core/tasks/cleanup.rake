require 'yaml'
require 'logger'
require 'active_record'
require 'casino_core/model'

namespace :casino_core do
  namespace :cleanup do
    desc 'Remove expired service tickets.'
    task service_tickets: 'casino_core:db:configure_connection' do
      [:consumed, :unconsumed].each do |type|
        rows_affected = CASinoCore::Model::ServiceTicket.send("cleanup_#{type}").length
        puts "Deleted #{rows_affected} #{type} service tickets."
      end
      rows_affected = CASinoCore::Model::ServiceTicket.cleanup_consumed_hard
      puts "Force deleted #{rows_affected} consumed service tickets."
    end

    desc 'Remove expired proxy tickets.'
    task proxy_tickets: 'casino_core:db:configure_connection' do
      [:consumed, :unconsumed].each do |type|
        rows_affected = CASinoCore::Model::ProxyTicket.send("cleanup_#{type}").length
        puts "Deleted #{rows_affected} #{type} proxy tickets."
      end
    end

    desc 'Remove expired login tickets.'
    task login_tickets: 'casino_core:db:configure_connection' do
      rows_affected = CASinoCore::Model::LoginTicket.cleanup
      puts "Deleted #{rows_affected} login tickets."
    end

    desc 'Remove expired inactive two-factor authenticators.'
    task two_factor_authenticators: 'casino_core:db:configure_connection' do
      rows_affected = CASinoCore::Model::TwoFactorAuthenticator.cleanup
      puts "Deleted #{rows_affected} inactive two-factor authenticators."
    end

    desc 'Remove expired ticket-granting tickets.'
    task ticket_granting_tickets: 'casino_core:db:configure_connection' do
      rows_affected = CASinoCore::Model::TicketGrantingTicket.cleanup.length
      puts "Deleted #{rows_affected} ticket-granting tickets."
    end

    desc 'Perform all cleanup tasks.'
    task all: [:ticket_granting_tickets, :service_tickets, :proxy_tickets, :login_tickets, :two_factor_authenticators] do
    end
  end
end
