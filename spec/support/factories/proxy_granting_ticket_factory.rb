require 'factory_girl'

FactoryGirl.define do
  factory :proxy_granting_ticket, class: CASino::ProxyGrantingTicket do
    association :granter, factory: :service_ticket
    sequence :ticket do |n|
      "PGT-ticket#{n}"
    end
    sequence :iou do |n|
      "PGTIOU-ticket#{n}"
    end
    sequence :pgt_url do |n|
      "https://www#{n}.example.org/pgtUrl"
    end
  end
end
