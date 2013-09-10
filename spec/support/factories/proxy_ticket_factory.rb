require 'factory_girl'

FactoryGirl.define do
  factory :proxy_ticket, class: CASino::ProxyTicket do
    proxy_granting_ticket
    sequence :ticket do |n|
      "PT-ticket#{n}"
    end
    sequence :service do |n|
      "imaps://mail#{n}.example.org/"
    end

    trait :consumed do
      consumed true
    end
  end
end
