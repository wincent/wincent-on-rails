require 'spec_helper'

feature 'resetting my passphrase' do
  background do
    email = Email.make! :address => 'joe@example.com'
  end

  scenario 'performing a reset', :js do
    visit '/resets/new'
    fill_in 'Email address', :with => 'joe@example.com'
    click_button 'Reset passphrase'
    page.should have_content('email has been sent to joe@example.com')
  end

  scenario 'hitting the reset limit', :js do
    7.times do
      visit '/resets/new'
      fill_in 'Email address', :with => 'joe@example.com'
      click_button 'Reset passphrase'
    end
    page.should have_content('exceeded the resets limit')
  end
end
