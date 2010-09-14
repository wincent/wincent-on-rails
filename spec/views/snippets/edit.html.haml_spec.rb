require 'spec_helper'

describe 'snippets/edit' do
  before do
    stub.proxy(view).render
    stub(view).render 'form'
    @snippet = Snippet.make!
  end

  it 'has breadcrumbs' do
    mock(view).breadcrumbs.with_any_args
    render
  end

  it 'renders the form partial' do
    mock(view).render 'form'
    render
  end

  it 'has a #show link' do
    render
    rendered.should have_selector('.links a', :href => snippet_path(@snippet))
  end

  it 'has a destroy button' do
    render
    rendered.should have_selector('.links ' +
      "form[action='#{snippet_path(@snippet)}'] " +
      'input[name=_method][value=delete]')
  end

  it 'has an #index link' do
    render
    rendered.should have_selector('.links a', :href => '/snippets')
  end
end
