require 'spec_helper'

describe 'snippets/new' do
  before do
    stub(view).render 'form'  # stub out render of partial
    stub.proxy(view).render   # but let initial render call through
  end

  it 'has breadcrumbs' do
    mock(view).breadcrumbs.with_any_args
    render
  end

  it 'renders the "form" partial' do
    mock(view).render 'form'
    render
  end

  it 'has a link back to the index' do
    render
    rendered.should have_selector('.links a', :href => '/snippets',
      :content => 'index')
  end
end
