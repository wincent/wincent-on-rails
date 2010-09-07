require 'spec_helper'

describe 'issues/search/new' do
  before do
    stub(view).render 'issues/search/form'
    stub.proxy(view).render
  end

  it 'has breadcrumbs' do
    mock(view).breadcrumbs.with_any_args
    render
  end

  it 'has an "all issues" link' do
    render
    rendered.should have_selector('div.links a', :href => issues_path)
  end

  it 'has a "support overview" link' do
    render
    rendered.should have_selector('div.links a', :href => support_path)
  end

  it 'has a "site search" link' do
    render
    rendered.should have_selector('div.links a', :href => new_search_path)
  end

  it 'renders the search form partial' do
    mock(view).render 'issues/search/form'
    render
  end
end
