require 'spec_helper'

describe 'snippets/index.atom' do
  let(:doc) { Nokogiri::XML(rendered) }

  before do
    @snippets = [Snippet.make! :description => 'foo', :body => 'a > b',
      :markup_type => Snippet::MarkupType::WIKITEXT]
  end

  it 'uses the custom Atom feed helper' do
    mock(view).custom_atom_feed
    render
  end

  it 'uses the first snippet update date as update date' do
    render
    doc.at_xpath('/atom:feed/atom:updated', ATOM_XMLNS).content.
      should == @snippets.first.updated_at.xmlschema
  end

  context 'no snippets' do
    it 'uses the "Rails Epoch" as update date' do
      @snippets = []
      render
      doc.at_xpath('/atom:feed/atom:updated', ATOM_XMLNS).content.
        should == RAILS_EPOCH.xmlschema
    end
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
  end
end
