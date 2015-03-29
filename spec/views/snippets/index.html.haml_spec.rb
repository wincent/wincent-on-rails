require 'spec_helper'

describe 'snippets/index' do
  before do
    @snippets = [Snippet.make!]
    @paginator = stub!.pagination_links.subject
    stub(view).render @snippets
    stub.proxy(view).render
  end

  it 'has breadcrumbs' do
    mock(view).breadcrumbs 'Snippets'
    render
  end

  it 'shows pagination links' do
    @paginator = mock!.pagination_links.subject
    render
  end

  it 'renders the snippets using a partial' do
    mock(view).render @snippets
    render
  end
end
