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
    expect(rendered).to have_link('show', href: snippet_path(@snippet))
  end

  it 'has a destroy button' do
    render
    expect(rendered).to have_css('.links ' +
      "form[action='#{snippet_path(@snippet)}'] " +
      'input[name=_method][value=delete]')
  end

  it 'has an #index link' do
    render
    expect(rendered).to have_link('all snippets', href: '/snippets')
  end
end
