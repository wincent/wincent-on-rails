require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe ForumsController do
  describe 'routing' do
    specify { get('/forums').should have_routing('forums#index') }
    specify { get('/forums/new').should have_routing('forums#new') }
    specify { get('/forums/foo-bar').should have_routing('forums#show', :id => 'foo-bar') }
    specify { get('/forums/foo-bar/edit').should have_routing('forums#edit', :id => 'foo-bar') }
    specify { put('/forums/foo-bar').should have_routing('forums#update', :id => 'foo-bar') }
    specify { delete('/forums/foo-bar').should have_routing('forums#destroy', :id => 'foo-bar') }
    specify { post('/forums').should have_routing('forums#create') }

    describe 'topics' do
      # only #new, #show, #edit, #update, #destroy, #create implemented while nested
      specify { get('/forums/foo-bar/topics/new').should have_routing('topics#new', :forum_id => 'foo-bar') }
      specify { get('/forums/foo-bar/topics/123').should have_routing('topics#show', :forum_id => 'foo-bar', :id => '123') }
      specify { get('/forums/foo-bar/topics/123/edit').should have_routing('topics#edit', :forum_id => 'foo-bar', :id => '123') }
      specify { put('/forums/foo-bar/topics/123').should have_routing('topics#update', :forum_id => 'foo-bar', :id => '123') }
      specify { delete('/forums/foo-bar/topics/123').should have_routing('topics#destroy', :forum_id => 'foo-bar', :id => '123') }
      specify { post('/forums/foo-bar/topics').should map_to('topics#create', :forum_id => 'foo-bar') }

      # topics#index is a no-op here, users go to forums#show to see a list of topics
      specify { get('/forums/foo-bar/topics').should_not be_recognized }

      describe 'comments' do
        # only #new and #create are implemented while nested
        # Rails BUG?: only map_to works here; map_from (and therefore also have_routing) do not
        specify { get('/forums/foo-bar/topics/123/comments/new').should map_to('comments#new', :forum_id => 'foo-bar', :topic_id => '123') }
        specify { post('/forums/foo-bar/topics/123/comments').should map_to('comments#create', :forum_id => 'foo-bar', :topic_id => '123') }

        # all other RESTful actions are no-ops
        specify { get('/forums/foo-bar/topics/123/comments').should_not be_recognized }
        specify { get('/forums/foo-bar/topics/123/comments/456').should_not be_recognized }
        specify { get('/forums/foo-bar/topics/123/comments/456/edit').should_not be_recognized }
        specify { put('/forums/foo-bar/topics/123/comments/456').should_not be_recognized }
        specify { delete('/forums/foo-bar/topics/123/comments/456').should_not be_recognized }
      end
    end

    describe 'helpers' do
      before do
        @forum = Forum.stub :permalink => 'foo-bar'
        @topic = Topic.stub :id => 123, :forum => @forum
      end

      describe 'forums_path' do
        specify { forums_path.should == '/forums' }
      end

      describe 'new_forum_path' do
        specify { new_forum_path.should == '/forums/new' }
      end

      describe 'forum_path' do
        specify { forum_path(@forum).should == '/forums/foo-bar' }
      end

      describe 'edit_forum_path' do
        specify { edit_forum_path(@forum).should == '/forums/foo-bar/edit' }
      end

      describe 'forum_topics_path' do
        specify { forum_topics_path(@forum).should == '/forums/foo-bar/topics' }
      end

      describe 'new_forum_topic_path' do
        specify { new_forum_topic_path(@forum).should == '/forums/foo-bar/topics/new' }
      end

      describe 'forum_topic_path' do
        specify { forum_topic_path(@forum, @topic).should == '/forums/foo-bar/topics/123' }
      end

      describe 'edit_forum_topic_path' do
        specify { edit_forum_topic_path(@forum, @topic).should == '/forums/foo-bar/topics/123/edit' }
      end

      describe 'forum_topic_comments_path' do
        specify { forum_topic_comments_path(@forum, @topic).should == '/forums/foo-bar/topics/123/comments' }
      end

      describe 'new_forum_topic_comment_path' do
        specify { new_forum_topic_comment_path(@forum, @topic).should == '/forums/foo-bar/topics/123/comments/new' }
      end
    end
  end
end
