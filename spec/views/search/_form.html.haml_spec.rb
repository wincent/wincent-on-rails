require 'spec_helper'

describe 'search/_form' do
  def do_render
    render
    #render '/search/form'
  end

  it 'has an "issue tracker search" link' do
    do_render
    rendered.should have_css('div.links a', :href => search_issues_path)
  end

  it 'has an "tag search" link' do
    do_render
    rendered.should have_css('div.links a', :href => search_tags_path)
  end

  it 'shows the search form' do
    do_render
    rendered.should have_css('form', :action => search_path) do |form|
      form.should have_css('input', :name => 'q', :type => 'text')
      form.should have_css('input', :value => 'Search', :type => 'submit')
    end
  end
end
