require 'spec_helper'

describe 'snippets/show.atom' do
  let(:doc) { Nokogiri::XML(rendered) }

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
    author = doc.at_xpath('/atom:feed/atom:author', ATOM_XMLNS)
    author.at_xpath('atom:name', ATOM_XMLNS).content.should == APP_CONFIG['admin_name']
    author.at_xpath('atom:email', ATOM_XMLNS).content.should == APP_CONFIG['admin_email']
  end

  describe 'entry' do
    let(:entry) { doc.at_xpath('/atom:feed/atom:entry', ATOM_XMLNS) }

    it 'uses the snippet title as title' do
      render
      entry.at_xpath('atom:title', ATOM_XMLNS).content.should == 'foo'
    end

    it 'includes the snippet body as HTML' do
      render
      entry.at_xpath('atom:content', ATOM_XMLNS).content.
        should == "<p>a &gt; b</p>\n"
    end

    it 'uses the administrator as the entry author' do
      render
      author = entry.at_xpath('atom:author', ATOM_XMLNS)
      author.at_xpath('atom:name', ATOM_XMLNS).content.
        should == APP_CONFIG['admin_name']
      author.at_xpath('atom:email', ATOM_XMLNS).content.
        should == APP_CONFIG['admin_email']
    end
  end

  describe 'comment' do
    let(:comment) { doc.xpath('/atom:feed/atom:entry', ATOM_XMLNS)[1] }

    it 'uses a description of the comment as title' do
      render
      comment.at_xpath('atom:title', ATOM_XMLNS).content.
        should =~ /New comment \(#\d+\) by .+/
    end

    it 'includes the comment body as HTML' do
      render
      comment.at_xpath('atom:content', ATOM_XMLNS).content.
        should == "<p>bar</p>\n"
    end

    it 'uses the comment author' do
      render
      comment.at_xpath('atom:author/atom:name', ATOM_XMLNS).content.
        should == @comments.first.user.display_name
    end
  end
end
