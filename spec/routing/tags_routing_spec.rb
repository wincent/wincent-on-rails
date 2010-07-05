require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe TagsController do
  describe 'routing' do
    it { get('/tags').should map('tags#index') }
    it { get('/tags/new').should map('tags#new') }
    it { get('/tags/foo.bar').should map('tags#show', :id => 'foo.bar') }
    it { get('/tags/foo.bar/edit').should map('tags#edit', :id => 'foo.bar') }
    it { put('/tags/foo.bar').should map('tags#update', :id => 'foo.bar') }
    it { delete('/tags/foo.bar').should map('tags#destroy', :id => 'foo.bar') }
    it { post('/tags').should map('tags#create') }

    it 'rejects invalid tag names' do
      pending 'requires change to RSpec be_routable matcher'
      # be_routeable feeds params into routes.recognize like so:
      #   routes.recognize(path, method)
      # where path is determined using
      #   params.values.first
      # and method is determined using
      #   params.keys.first
      # ie. it expects a hash of format { :get => 'path' }
      # but we are handing it a hash of { :method => :get, :path => 'path' }

      # only letters, numbers and periods allowed
      get('/tags/foo.2').should be_routable
      get('/tags/foo-bar').should_not be_routable
    end

    describe 'non-RESTful routes' do
      it { get('/tags/search').should map('tags#search') }
    end

    describe 'helpers' do
      before do
        # we use an tag with a "tricky" id (containing a period, which is
        # usually a format separator) to test the routes
        @tag = Tag.stub :name => 'foo.bar'
      end

      describe 'tags_path' do
        it { tags_path.should == '/tags' }
      end

      describe 'new_tag_path' do
        it { new_tag_path.should == '/tags/new' }
      end

      describe 'tag_path' do
        it { tag_path(@tag).should == '/tags/foo.bar' }
      end

      describe 'edit_tag_path' do
        it { edit_tag_path(@tag).should == '/tags/foo.bar/edit' }
      end
    end
  end
end
