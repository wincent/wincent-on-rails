require 'spec_helper'

describe 'snippets/_snippet' do
  let(:snippet) do
    Snippet.make! body: "''foo''", markup_type: Snippet::MarkupType::WIKITEXT
  end

  def do_render
    render 'snippets/snippet', snippet: snippet
  end

  it 'links to the snippet' do
    do_render
    expect(rendered).to have_link('Snippet', href: snippet_path(snippet))
  end

  it 'shows timeinfo for the snippet' do
    mock(view).timeinfo snippet
    do_render
  end

  it 'has a comment link' do
    do_render
    expect(rendered).
      to have_link('comment', href: new_snippet_comment_path(snippet))
  end

  it 'shows the snippet body HTML' do
    do_render
    expect(rendered).to have_css('em', text: 'foo')
  end
end
