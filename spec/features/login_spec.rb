require 'spec_helper'

feature 'Login' do
  include CASino::Engine.routes.url_helpers

  scenario 'with valid username and password' do
    integration_sign_in

    expect(page).to have_content('Logout')
  end

  scenario 'with invalid username' do
    integration_sign_in username: 'lalala', password: 'foobar123'

    expect(page).to have_content('Login')
  end

  scenario 'with blank password' do
    integration_sign_in password: ''

    expect(page).to have_content('Login')
  end
end