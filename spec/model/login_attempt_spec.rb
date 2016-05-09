require 'spec_helper'

describe CASino::LoginAttempt do
  subject { described_class.new user_agent: 'TestBrowser' }

  it_behaves_like 'has browser info'
end
