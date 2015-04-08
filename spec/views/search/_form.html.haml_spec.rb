require 'spec_helper'

describe 'search/_form' do
  it 'has an "issue tracker search" link' do
    render
    expect(rendered).to have_link('issue tracker search', href: search_issues_path)
  end

  it 'has an "tag search" link' do
    render
    expect(rendered).to have_link('tag search', href: search_tags_path)
  end

  it 'shows the search form' do
    render
    within("form[action='#{search_path}']") do |form|
      expect(form).to have_css('input[name="q"][type="text"]')
      expect(form).to have_css('input[value="Search"][type="submit"]')
    end
  end
end
