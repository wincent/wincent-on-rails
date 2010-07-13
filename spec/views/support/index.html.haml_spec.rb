require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'support/index' do
  before do
    @issues = [Issue.make!]
    stub(view).render 'issues/issues'
    stub.proxy(view).render
  end

  it 'has a forums link' do
    render
    rendered.should have_selector('div.links a[href="/forums"]')
  end

  it 'has a "lost license code" link' do
    render
    rendered.should have_selector('div.links a[href="https://secure.wincent.com/a/support/registration/"]')
  end

  it 'has an "all issues" link' do
    render
    rendered.should have_selector('div.links a[href="/issues"]')
  end

  it 'has a search link' do
    render
    rendered.should have_selector('div.links a[href="/issues/search"]')
  end

  it 'has a "new issue" link' do
    render
    rendered.should have_selector('div.links a[href="/issues/new"]')
  end

  it 'renders the issues list partial' do
    mock(view).render 'issues/issues'
    render
  end
end
