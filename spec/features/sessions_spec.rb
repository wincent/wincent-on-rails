require 'spec_helper'

feature "Logging in to the site:" do
  background do
    @email = Email.make!
  end

  def log_in
    visit '/login'
    fill_in 'Email address', :with => @email.address
    fill_in 'Passphrase', :with => Sham.passphrase
    click_button 'Log in'
  end

  scenario 'logging in and seeing a flash', :js do
    log_in
    page.should have_content('Successfully logged in')
  end

  scenario 'logging out and seeing a flash', :js do
    log_in
    visit '/logout'
    page.should have_content('You have logged out successfully')
  end

  scenario 'trying to log out when not logged in and seeing a flash', :js do
    visit '/logout'
    page.should have_content("Can't log out (weren't logged in)")
  end

  scenario 'failing to log in', :js do
    visit '/login'
    fill_in 'Email address', :with => 'not an email address'
    fill_in 'Passphrase', :with => 'not a passphrase'
    click_button 'Log in'
    page.should have_content('Invalid email or passphrase')
  end

  scenario 'dynamic "log in"/"log out" links (when logged in)', :js do
    log_in
    page.should have_content('log out')
    page.should_not have_content('log in')
  end

  scenario 'dynamic "log in"/"log out" links (when logged out)', :js do
    visit '/'
    page.should have_content('log in')
    page.should_not have_content('log out')
  end

  scenario 'dynamic "log in"/"log out" links (with no JavaScript)' do
    visit '/'
    page.should have_content('log in')
    page.should have_content('log out')
  end
end