require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'topics/show.html.haml' do

  before do
    @title = Sham.random
    @topic = Topic.make!({ :title => @title })
    @forum = @topic.forum
    @comments = []
    @comment = @topic.comments.build
  end

  it 'shows breadcrumbs' do
    mock(view).breadcrumbs.with_any_args
    render
  end

  it 'shows the topic title as a major heading' do
    render
    rendered.should have_selector('h1.major', :content => @title)
  end
end
