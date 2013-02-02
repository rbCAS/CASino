require 'factory_girl'

FactoryGirl.define do
  factory :ticket_granting_ticket, class: CASinoCore::Model::TicketGrantingTicket do
    user
    sequence :ticket do |n|
      "TGC-ticket#{n}"
    end
    user_agent 'TestBrowser 1.0'
  end
end
