require 'spec_helper'

describe TagsController do
  describe '#index' do
    before do
      @foo = Tag.make! :name => 'foo'
      @bar = Tag.make! :name => 'bar'
      @baz = Tag.make! :name => 'baz'
      Article.make!.tag 'foo', 'bar', 'baz'
    end

    it 'finds and assigns tags' do
      get :index
      expect(assigns[:tags].to_a).to match_array([@foo, @bar, @baz])
    end

    it 'does not find or assign tags with no taggings' do
      tag = Tag.make! :name => 'orphan'
      get :index
      expect(assigns[:tags]).not_to include(tag)
    end

    it 'orders tags by name' do
      get :index
      expect(assigns[:tags].to_a).to eq([@bar, @baz, @foo])
    end

    it 'renders tags/index' do
      get :index
      expect(response).to render_template('tags/index')
    end
  end

  describe '#show' do
    before do
      @tag = Tag.make! :name => 'foo'
    end

    def do_get
      get :show, :id => 'foo'
    end

    it 'finds and assigns the tag' do
      do_get
      expect(assigns[:tag]).to eq(@tag)
    end

    it 'finds and assigns grouped taggables' do
      mock(Tagging).grouped_taggables_for_tag @tag, anything, anything
      do_get
    end

    it 'finds and assigns reachable tags' do
      mock(Tag).tags_reachable_from_tags @tag
      do_get
    end
  end

  describe '#edit' do
    let(:tag) { Tag.make! }

    def do_request
      get :edit, :id => tag.to_param
    end

    it_has_behavior 'require_admin'

    context 'as an admin user' do
      before do
        log_in_as_admin
      end

      it 'finds and assigns the tag' do
        do_request
        expect(assigns[:tag]).to eq(tag)
      end

      it 'renders tags/edit' do
        do_request
        expect(response).to render_template('tags/edit')
      end

      it 'succeeds' do
        do_request
        expect(response).to be_success
      end
    end
  end

  describe '#update' do
    let(:tag) { Tag.make! }

    before do
      @params = { 'name' => 'foo' }
    end

    def do_request
      put :update, :id => tag.to_param, :tag => @params
    end

    it_has_behavior 'require_admin'

    context 'admin user' do
      before do
        log_in_as_admin
      end

      it 'finds and assigns the tag' do
        do_request
        expect(assigns[:tag]).to eq(tag)
      end

      it 'updates the attributes' do
        do_request
        expect(assigns[:tag].name).to eq('foo')
      end

      it 'shows a flash' do
        do_request
        expect(flash[:notice]).to match(/successfully updated/i)
      end

      it 'redirects to #show' do
        do_request
        expect(response).to redirect_to('/tags/foo')
      end

      context 'failed update' do
        before do
          stub(Tag).find_by_name(tag.name).stub!.update_attributes { false }
        end

        it 'shows a flash' do
          do_request
          expect(flash[:error]).to match(/update failed/i)
        end

        it 'renders #edit' do
          do_request
          expect(response).to render_template('tags/edit')
        end
      end
    end
  end

  describe '#search' do
    before do
      Article.make!.tag 'foo'
      @tag = Tag.find_by_name 'foo'
    end

    it 'trims excess tags (more than 10)' do
      get :search, :q => '1 2 3 4 5 6 7 8 9 10 11'
      expect(flash[:notice].any? do |notice|
        notice =~ /excess tags stripped/i
      end).to eq(true)
    end

    it 'excludes non-existent tags' do
      get :search, :q => 'foo bar'
      expect(flash[:notice].any? do |notice|
        notice =~ /non-existent tags excluded/i
      end).to eq(true)
    end

    it 'finds and assigns tags' do
      mock.proxy(Tagging).grouped_taggables_for_tag_names ['foo'], anything, anything
      get :search, :q => 'foo'
      expect(assigns[:tags][:found]).to eq([@tag])
    end

    it 'finds and assigns taggables' do
      mock.proxy(Tagging).grouped_taggables_for_tag_names ['foo'], anything, anything
      get :search, :q => 'foo'
      expect(assigns[:taggables]).not_to be_nil # too lazy to actually spec this
    end

    it 'finds and assigns reachable tags' do
      mock(Tag).tags_reachable_from_tags([@tag]) { :reachables }
      get :search, :q => 'foo'
      expect(assigns[:reachable_tags]).to eq(:reachables)
    end

    context 'no params' do
      it 'renders tags/search' do
        get :search
        expect(response).to render_template 'tags/search'
      end
    end
  end
end
