require 'spec_helper'

describe 'snippets/_snippet' do
  let(:snippet) do
    Snippet.make! :body => "''foo''", :markup_type => Snippet::MarkupType::WIKITEXT
  end

  def do_render
    render 'snippets/snippet', :snippet => snippet
  end

  it 'links to the snippet' do
    do_render
    rendered.should have_selector('a', :href => snippet_path(snippet))
  end

  it 'shows timeinfo for the snippet' do
    mock(view).timeinfo snippet
    do_render
  end

  it 'has a comment link' do
    do_render
    rendered.
      should have_selector('a', :href => new_snippet_comment_path(snippet))
  end

  it 'shows the snippet body HTML' do
    do_render
    rendered.should have_selector('em', :content => 'foo')
  end
end
