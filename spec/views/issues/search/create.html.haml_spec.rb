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
    expect(rendered).to have_link('all issues', href: issues_path)
  end

  it 'has a "search again" link' do
    render
    expect(rendered).to have_link('search again')
  end

  it 'hides the search div upon initial display' do
    render
    expect(rendered).to have_css('div#issue_search', visible: false)
  end

  it 'has a "new issue" link' do
    render
    expect(rendered).to have_link('open a ticket', href: new_issue_path)
  end

  it 'has a "support overview" link' do
    render
    expect(rendered).to have_link('support overview', href: support_path)
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
