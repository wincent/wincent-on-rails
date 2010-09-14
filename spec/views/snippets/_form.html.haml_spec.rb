require 'spec_helper'

describe 'snippets/_form' do
  before do
    @snippet = Snippet.make!
    stub.proxy(view).render
    stub(view).render 'shared/error_messages', :model => @snippet
    stub(view).render 'preview'
  end

  it 'includes ajax.js' do
    mock(view).javascript_include_tag 'ajax'
    render
  end

  it 'renders the error messages partial' do
    mock(view).render 'shared/error_messages', :model => @snippet
    render
  end

  it 'has a form' do
    render
    rendered.should have_selector('form', :action => snippet_path(@snippet))
  end

  it 'renders the preview partial' do
    mock(view).render 'preview'
    render
  end
end
