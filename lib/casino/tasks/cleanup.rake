require 'yaml'
require 'logger'
require 'active_record'

namespace :casino do
  namespace :cleanup do
    desc 'Remove expired service tickets.'
    task service_tickets: :environment do
      [:consumed, :unconsumed].each do |type|
        rows_affected = CASino::ServiceTicket.send("cleanup_#{type}")
        if rows_affected.respond_to? :length
          rows_affected = rows_affected.length
        end
        puts "Deleted #{rows_affected} #{type} service tickets."
      end
      rows_affected = CASino::ServiceTicket.cleanup_consumed_hard
      puts "Force deleted #{rows_affected} consumed service tickets."
    end

    desc 'Remove expired proxy tickets.'
    task proxy_tickets: :environment do
      [:consumed, :unconsumed].each do |type|
        rows_affected = CASino::ProxyTicket.send("cleanup_#{type}").length
        puts "Deleted #{rows_affected} #{type} proxy tickets."
      end
    end

    desc 'Remove expired login tickets.'
    task login_tickets: :environment do
      rows_affected = CASino::LoginTicket.cleanup
      puts "Deleted #{rows_affected} login tickets."
    end

    desc 'Remove expired auth token tickets.'
    task auth_token_tickets: :environment do
      rows_affected = CASino::AuthTokenTicket.cleanup
      puts "Deleted #{rows_affected} auth token tickets."
    end

    desc 'Remove expired inactive two-factor authenticators.'
    task two_factor_authenticators: :environment do
      rows_affected = CASino::TwoFactorAuthenticator.cleanup
      puts "Deleted #{rows_affected} inactive two-factor authenticators."
    end

    desc 'Remove expired ticket-granting tickets.'
    task ticket_granting_tickets: :environment do
      rows_affected = CASino::TicketGrantingTicket.cleanup.length
      puts "Deleted #{rows_affected} ticket-granting tickets."
    end

    task :acquire_lock do
      $cleanup_lock = File.open('tmp/cleanup.lock', File::RDWR | File::CREAT, 0644)
      lock_aquired = $cleanup_lock.flock(File::LOCK_NB | File::LOCK_EX)
      if lock_aquired === false
        $stderr.puts 'Could not acquire lock, other cleanup task already running?'
        exit 1
      end
    end

    desc 'Perform all cleanup tasks.'
    task all: [:acquire_lock,
               :ticket_granting_tickets,
               :service_tickets,
               :proxy_tickets,
               :auth_token_tickets,
               :login_tickets,
               :two_factor_authenticators] do
    end
  end
end
