require 'spec_helper'

describe 'snippets/_preview' do
  before do
    @snippet = Snippet.make! :body => "''foo''",
      :markup_type => Snippet::MarkupType::WIKITEXT
  end

  it 'shows the snippet title' do
    mock(view).snippet_title @snippet
    render 'snippets/preview'
  end

  it 'shows the snippet body HTML' do
    render 'snippets/preview'
    rendered.should have_selector('em', :content => 'foo')
  end
end
