require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe TagsController do
  describe 'routing' do
    specify { get('/tags').should map('tags#index') }
    specify { get('/tags/new').should map('tags#new') }
    specify { get('/tags/foo.bar').should map('tags#show', :id => 'foo.bar') }
    specify { get('/tags/foo.bar/edit').should map('tags#edit', :id => 'foo.bar') }
    specify { put('/tags/foo.bar').should map('tags#update', :id => 'foo.bar') }
    specify { delete('/tags/foo.bar').should map('tags#destroy', :id => 'foo.bar') }
    specify { post('/tags').should map('tags#create') }

    it 'rejects invalid tag names' do
      # only letters, numbers and periods allowed
      get('/tags/foo.2').should be_recognized
      get('/tags/foo-bar').should_not be_recognized
    end

    describe 'non-RESTful routes' do
      specify { get('/tags/search').should map('tags#search') }
    end

    describe 'helpers' do
      before do
        # we use an tag with a "tricky" id (containing a period, which is
        # usually a format separator) to test the routes
        @tag = Tag.stub :name => 'foo.bar'
      end

      describe 'tags_path' do
        specify { tags_path.should == '/tags' }
      end

      describe 'new_tag_path' do
        specify { new_tag_path.should == '/tags/new' }
      end

      describe 'tag_path' do
        specify { tag_path(@tag).should == '/tags/foo.bar' }
      end

      describe 'edit_tag_path' do
        specify { edit_tag_path(@tag).should == '/tags/foo.bar/edit' }
      end
    end
  end
end
