require 'spec_helper'

feature 'Logout' do
  include CASino::Engine.routes.url_helpers

  scenario 'when logged in' do
    integration_sign_in
    click_link 'Logout'

    expect(page).to have_content('logged out')
  end
end
