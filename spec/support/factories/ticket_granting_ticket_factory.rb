require 'factory_girl'

FactoryGirl.define do
  factory :ticket_granting_ticket, class: CASinoCore::Model::TicketGrantingTicket do
    sequence :ticket do |n|
      "TGC-ticket#{n}"
    end
    authenticator 'test'
    username 'test'
    extra_attributes({ fullname: "Test User", age: 15, roles: [:user] })
    user_agent 'TestBrowser 1.0'
  end
end
