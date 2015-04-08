require 'spec_helper'

describe 'snippets/_preview' do
  before do
    @snippet = Snippet.make! body: "''foo''",
      markup_type: Snippet::MarkupType::WIKITEXT
  end

  it 'shows the snippet title' do
    mock(view).snippet_title @snippet
    render
  end

  it 'shows the snippet body HTML' do
    render
    expect(rendered).to have_css('em', text: 'foo')
  end
end
