require 'spec_helper'

describe 'topics/show.html.haml' do

  before do
    @title = Sham.random
    @topic = Topic.make!(title: @title)
    @forum = @topic.forum
    @comments = []
    @comment = @topic.comments.new
  end

  it 'shows breadcrumbs' do
    mock(view).breadcrumbs.with_any_args
    render
  end

  it 'shows the topic title as a major heading' do
    render
    expect(rendered).to have_css('h1.major', text: @title)
  end
end
