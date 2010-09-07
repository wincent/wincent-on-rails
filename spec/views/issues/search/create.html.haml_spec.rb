require 'spec_helper'

describe 'issues/search/create' do
  before do
    @issues = [Issue.make!]
    stub(view).render 'issues/search/form'
    stub(view).render 'issues/issues'
    stub.proxy(view).render
  end

  it 'has an "all issues" link' do
    render
    rendered.should have_selector('div.links a', :href => issues_path)
  end

  it 'has a "search again" link' do
    render
    # this is a complex JS link, so won't try too hard to test the actual onclick attribute
    rendered.should have_selector('div.links a', :content => 'search again')
  end

  it 'hides the search div upon initial display' do
    render
    rendered.should have_selector('div#issue_search', :style => 'display:none;')
  end

  it 'has a "new issue" link' do
    render
    rendered.should have_selector('div.links a', :href => new_issue_path)
  end

  it 'has a "support overview" link' do
    render
    rendered.should have_selector('div.links a', :href => support_path)
  end

  it 'renders the search form partial' do
    mock(view).render 'issues/search/form'
    render
  end

  it 'renders the issues list partial' do
    mock(view).render 'issues/issues'
    render
  end
end
