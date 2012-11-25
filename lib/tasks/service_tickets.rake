namespace :service_tickets do
  desc 'Remove expired service tickets.'
  task cleanup: :environment do
    [:consumed, :unconsumed].each do |type|
      rows_affected = ServiceTicket.send("cleanup_#{type}")
      puts "Deleted #{rows_affected} #{type} service tickets."
    end
  end
end
