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

    desc 'Perform all cleanup tasks.'
    task all: [:service_tickets, :proxy_tickets, :login_tickets] do
    end
  end
end
