require File.expand_path('../spec_helper', File.dirname(__FILE__))

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
      assigns[:tags].to_a.should =~ [@foo, @bar, @baz]
    end

    it 'does not find or assign tags with no taggings' do
      tag = Tag.make! :name => 'orphan'
      get :index
      assigns[:tags].should_not include(tag)
    end

    it 'orders tags by name' do
      get :index
      assigns[:tags].to_a.should == [@bar, @baz, @foo]
    end

    it 'renders tags/index' do
      get :index
      response.should render_template('tags/index')
    end
  end
end
