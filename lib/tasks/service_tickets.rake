namespace :service_tickets do
  desc 'Remove expired service tickets.'
  task cleanup: :environment do
    rows_affected = ServiceTicket.cleanup
    puts "Deleted #{rows_affected} service tickets."
  end
end
