require 'spec_helper'

describe 'Session overview' do
  include CASino::Engine.routes.url_helpers

  subject { page }

  context 'when logged in' do
    let(:login_attempt) do
      FactoryGirl.create :login_attempt, created_at: Time.zone.parse('2015-01-01 09:10'),
                                         username: 'testuser'
    end

    before do
      sign_in
      login_attempt.touch
      visit login_attempts_path
    end

    it { should have_text('TestBrowser') }
    it { should have_text('133.133.133.133') }
    it { should have_text('2015-01-01 09:10') }
  end
end
