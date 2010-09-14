require 'spec_helper'
require 'hpricot'

describe 'snippets/index.atom' do
  let(:doc) { Hpricot.XML(rendered) }

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
    doc.at('feed').at('updated').innerHTML.
      should == @snippets.first.updated_at.xmlschema
  end

  context 'no snippets' do
    it 'uses the "Rails Epoch" as update date' do
      @snippets = []
      render
      doc.at('feed').at('updated').innerHTML.should == RAILS_EPOCH.xmlschema
    end
  end

  it 'uses the administrator as the feed author' do
    render
    author = doc.at('feed').at('author')
    author.at('name').innerHTML.should == APP_CONFIG['admin_name']
    author.at('email').innerHTML.should == APP_CONFIG['admin_email']
  end

  describe 'entry' do
    let(:entry) { doc.at('feed').at('entry') }

    it 'uses the snippet title as title' do
      render
      entry.at('title').innerHTML.should == 'foo'
    end

    it 'includes the snippet body as escaped HTML' do
      render
      entry.at('content').innerHTML.
        should == "&lt;p&gt;a &amp;gt; b&lt;/p&gt;\n"
    end
  end
end
