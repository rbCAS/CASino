require 'factory_girl'

FactoryGirl.define do
  factory :login_attempt, class: CASino::LoginAttempt do
    username 'some@body.ch'
    successful true
    user_ip '133.133.133.133'
    user_agent 'TestBrowser'
  end
end
