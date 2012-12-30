require 'factory_girl'

FactoryGirl.define do
  factory :login_ticket, class: CASinoCore::Model::LoginTicket do
    sequence :ticket do |n|
      "LT-ticket#{n}"
    end

    trait :consumed do
      consumed true
    end
  end
end
