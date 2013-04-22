require 'spec_helper'

describe 'Logout' do
  include CASino::Engine.routes.url_helpers

  subject { page }

  context 'when logged in' do
    before do
      sign_in
      click_link 'Logout'
    end

    it { should have_content('logged out') }
  end
end
