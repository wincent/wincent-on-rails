require 'spec_helper'

feature 'the wiki index' do
  scenario 'no articles in the wiki' do
    visit '/wiki'
    page.should have_content('Recently updated')
    page.should have_content('Top tags')
  end

  scenario 'several articles in the wiki' do
    Article.make! :title => 'foo'
    Article.make! :title => 'bar'
    Article.make! :title => 'baz'
    visit '/wiki'
    page.should have_content('Recently updated')
    page.should have_content('foo')
    page.should have_content('bar')
    page.should have_content('baz')
  end
end
