require 'spec_helper'

describe 'search/search' do
  before do
    stub.proxy(view).render
  end

  it 'shows breadcrumbs' do
    mock(view).breadcrumbs 'Search'
    render
  end

  context 'no query parameter' do
    it 'renders the "form" partial' do
      mock(view).render 'search/form'
      render
    end
  end

  context 'with a query parameter' do
    it 'renders the "results" partial' do
      @query = 'foo'
      mock(view).render 'search/results'
      render
    end
  end
end
