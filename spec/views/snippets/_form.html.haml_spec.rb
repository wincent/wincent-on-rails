require 'spec_helper'

describe 'snippets/_form' do
  before do
    @snippet = Snippet.make!
    stub.proxy(view).render
    stub(view).render 'shared/error_messages', model: @snippet
    stub(view).render 'preview'
  end

  it 'renders the error messages partial' do
    mock(view).render 'shared/error_messages', model: @snippet
    render
  end

  it 'has a form' do
    render
    expect(rendered).to have_css("form[action='#{snippet_path(@snippet)}']")
  end

  it 'renders the preview partial' do
    mock(view).render 'preview'
    render
  end
end
