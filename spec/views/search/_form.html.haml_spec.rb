require 'spec_helper'

describe 'search/_form' do
  it 'has an "issue tracker search" link' do
    render
    rendered.should have_link('issue tracker search', href: search_issues_path)
  end

  it 'has an "tag search" link' do
    render
    rendered.should have_link('tag search', href: search_tags_path)
  end

  it 'shows the search form' do
    render
    within("form[action='#{search_path}']") do |form|
      form.should have_css('input[name="q"][type="text"]')
      form.should have_css('input[value="Search"][type="submit"]')
    end
  end
end
