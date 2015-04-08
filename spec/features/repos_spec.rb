require 'spec_helper'

feature 'repository browser' do
  scenario 'visiting /repos' do
    visit '/repos'
    expect(page).to have_content('Repositories')
  end
end
