require 'spec_helper'

feature 'repository browser' do
  scenario 'visiting /repos' do
    visit '/repos'
    page.should have_content('Repositories')
  end
end
