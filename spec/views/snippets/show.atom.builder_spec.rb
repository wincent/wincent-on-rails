require 'spec_helper'
require 'hpricot'

describe 'snippets/show.atom' do
  let(:doc) { Hpricot.XML(rendered) }

  before do
    @snippet = Snippet.make! :description => 'foo', :body => 'a > b',
      :markup_type => Snippet::MarkupType::WIKITEXT
    @comments = [Comment.make! :body => 'bar', :commentable => @snippet]
  end

  it 'uses the custom Atom feed helper' do
    mock(view).custom_atom_feed
    render
  end

  it 'uses the last activity date as update date' do
    mock.proxy(view).last_activity @snippet, @comments
    render
  end

  it 'uses the administrator as the feed author' do
    render
    author = doc.at('feed/author')
    author.at('name').innerHTML.should == APP_CONFIG['admin_name']
    author.at('email').innerHTML.should == APP_CONFIG['admin_email']
  end

  describe 'entry' do
    let(:entry) { doc.at('feed/entry') }

    it 'uses the snippet title as title' do
      render
      entry.at('title').innerHTML.should == 'foo'
    end

    it 'includes the snippet body as escaped HTML' do
      render
      entry.at('content').innerHTML.
        should == "&lt;p&gt;a &amp;gt; b&lt;/p&gt;\n"
    end

    it 'uses the administrator as the entry author' do
      render
      author = entry.at('author')
      author.at('name').innerHTML.should == APP_CONFIG['admin_name']
      author.at('email').innerHTML.should == APP_CONFIG['admin_email']
    end
  end

  describe 'comment' do
    let(:comment) { (doc/'entry')[1] }

    it 'uses a description of the comment as title' do
      render
      comment.at('title').innerHTML.should =~ /New comment \(#\d+\) by .+/
    end

    it 'includes the comment body as escaped HTML' do
      render
      comment.at('content').innerHTML.should == "&lt;p&gt;bar&lt;/p&gt;\n"
    end

    it 'uses the comment author' do
      render
      comment.at('author/name').innerHTML.
        should == @comments.first.user.display_name
    end
  end
end
