require File.dirname(__FILE__) + '/acceptance_helper'

feature 'Logging in to the site' do
  scenario 'dynamic "log in"/"log out" links (with no JavaScript)' do
    visit '/'
    page.should have_content('log in')
    page.should have_content('log out')
  end
end
