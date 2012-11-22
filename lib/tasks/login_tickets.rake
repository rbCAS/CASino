namespace :login_tickets do
  desc 'Remove expired login tickets.'
  task cleanup: :environment do
    LoginTicket.cleanup
  end
end
