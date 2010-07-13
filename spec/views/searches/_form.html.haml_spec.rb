require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'searches/_form' do
  def do_render
    render
    #render '/search/form'
  end

  it 'has an "issue tracker search" link' do
    do_render
    rendered.should have_selector('div.links a', :href => search_issues_path)
  end

  it 'has an "tag search" link' do
    do_render
    rendered.should have_selector('div.links a', :href => search_tags_path)
  end

  it 'shows the search form' do
    do_render
    rendered.should have_selector('form', :action => searches_path) do |form|
      form.should have_selector('input', :name => 'query', :type => 'text')
      form.should have_selector('input', :value => 'Search', :type => 'submit')
    end
  end
end
