require 'factory_girl'

FactoryGirl.define do
  factory :two_factor_authenticator, class: CASinoCore::Model::TwoFactorAuthenticator do
    ticket_granting_ticket
    secret do |a|
      ROTP::Base32.random_base32
    end
  end
end
