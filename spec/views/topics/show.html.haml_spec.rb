require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe '/topics/show' do
  include TopicsHelper

  before do
    @title              = FR::random_string
    assigns[:topic]     = @topic = create_topic({ :title => @title })
    assigns[:forum]     = @forum = @topic.forum
    assigns[:comments]  = []
    assigns[:comment]   = @topic.comments.build
    render '/topics/show'
  end

  it 'should show breadcrumbs' do
    response.should have_tag('div#breadcrumbs', /#{@title}/) do
      with_tag 'a[href=?]', root_path
      with_tag 'a[href=?]', forums_path
      with_tag 'a[href=?]', forum_path(@forum)
    end
  end

  it 'should show the topic title as a major heading' do
    response.should have_tag('h1.major', /#{@title}/)
  end
end
