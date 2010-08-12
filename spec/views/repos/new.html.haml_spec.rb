require File.expand_path('../../spec_helper', File.dirname(__FILE__))

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
    rendered.should have_selector('form[method=post]', :action => '/repos')
  end

  it 'has a link to the repos index' do
    render
    rendered.should have_selector('.links a', :href => '/repos')
  end
end
