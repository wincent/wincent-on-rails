require 'spec_helper'

feature 'the wiki index' do
  scenario 'no articles in the wiki' do
    visit '/wiki'
    expect(page).to have_content('Recently updated')
    expect(page).to have_content('Top tags')
  end

  scenario 'several articles in the wiki' do
    Article.make! :title => 'foo'
    Article.make! :title => 'bar'
    Article.make! :title => 'baz'
    visit '/wiki'
    expect(page).to have_content('Recently updated')
    expect(page).to have_content('foo')
    expect(page).to have_content('bar')
    expect(page).to have_content('baz')
  end
end
