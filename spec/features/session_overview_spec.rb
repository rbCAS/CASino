require 'spec_helper'

describe 'Session overview' do
  include CASino::Engine.routes.url_helpers

  subject { page }

  context 'when logged in' do
    before do
      sign_in
      visit sessions_path
    end

    it { should have_link('Logout', href: logout_path) }
    it { should have_text('Your Active Sessions') }
    it { should have_text('Active Session') }

    context 'without other sessions' do
      it { should_not have_button('End session') }
    end

    context 'when other sessions exist' do
      before do
        in_browser(:other) do
          sign_in
        end
        visit sessions_path
      end
      it { should have_button('End session') }
    end

    context 'with two-factor authentication disabled' do
      before do
        in_browser(:other) do
          sign_in
        end
        visit sessions_path
      end
      it { should have_link('Enable', href: new_two_factor_authenticator_path) }
      it { should_not have_button('Disable') }
    end

    context 'with two-factor authentication enabled' do
      before { enable_two_factor_authentication }
      it { should_not have_link('Enable', href: new_two_factor_authenticator_path) }
      it { should have_button('Disable') }
    end
  end

  context 'when not logged in' do
    before { visit sessions_path }

    it { should have_button('Login') }
    its(:current_path) { should == login_path }
  end
end
