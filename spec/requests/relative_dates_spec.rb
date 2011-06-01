require 'spec_helper'

feature 'dynamic relative dates' do
  background do
    Article.make! :created_at => 5.days.ago
  end

  scenario 'viewing the wiki index with JavaScript enabled', :js do
    visit '/wiki'
    page.should have_content('5 days ago')
  end

  scenario 'viewing the wiki index without JavaScript' do
    visit '/wiki'
    page.should_not have_content('5 days ago')
  end
end
