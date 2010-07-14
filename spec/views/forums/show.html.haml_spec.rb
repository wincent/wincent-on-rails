require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'forums/show' do
  before do
    @name = Sham.random
    @forum = Forum.make! :name => @name
    @topics = []
  end

  it 'has breadcrumbs' do
    mock(view).breadcrumbs.with_any_args
    render
  end

  it 'shows the forum name as a major heading' do
    render
    rendered.should have_selector('h1.major', :content => @name)
  end
end
