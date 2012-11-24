namespace :login_tickets do
  desc 'Remove expired login tickets.'
  task cleanup: :environment do
    rows_affected = LoginTicket.cleanup
    puts "Deleted #{rows_affected} login tickets."
  end
end
