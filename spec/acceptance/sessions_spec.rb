require File.dirname(__FILE__) + '/acceptance_helper'

feature 'Logging in to the site' do
  before :each do
    # BUG: routing assumes that /products/synergy exists
    # if we visit "/" without creating the product first we get a
    # 404 and an infinite redirection loop (back to "/")
    # getting a real products#index action finished is a high priority
    Product.make! :permalink => 'synergy'
  end

  scenario 'logging in and seeing a flash', :js => true do
    email = Email.make!
    visit '/login'
    fill_in 'Email address', :with => email.address
    fill_in 'Passphrase', :with => Sham.passphrase
    click_button 'Log in'
    page.should have_content('Successfully logged in')
  end

  pending 'logging out and seeing a flash'
  pending 'trying to log out when not logged in and seeing a flash'
  pending 'dynamic "log in"/"log out" links (when logged in)'
  pending 'dynamic "log in"/"log out" links (when logged out)'

  scenario 'dynamic "log in"/"log out" links (with no JavaScript)' do
    visit '/'
    page.should have_content('log in')
    page.should have_content('log out')
  end
end
