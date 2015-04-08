require 'spec_helper'

describe 'repos/new' do
  before do
    @repo = Repo.new
  end

  it 'has breadcrumbs' do
    mock(view).breadcrumbs.with_any_args
    render
  end

  it 'displays error messages' do
    stub.proxy(view).render
    mock(view).render('shared/error_messages', anything)
    render
  end

  it 'has a form for the repo' do
    render
    expect(rendered).to have_css("form[method=post][action='/repos']")
  end

  it 'has a link to the repos index' do
    render
    expect(rendered).to have_link('index', href: '/repos')
  end
end
