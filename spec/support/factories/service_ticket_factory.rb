require 'factory_girl'

FactoryGirl.define do
  factory :service_ticket, class: CASino::ServiceTicket do
    ticket_granting_ticket
    sequence :ticket do |n|
      "ST-ticket#{n}"
    end
    sequence :service do |n|
      "http://www#{n}.example.org/"
    end

    trait :consumed do
      consumed true
    end
  end
end
