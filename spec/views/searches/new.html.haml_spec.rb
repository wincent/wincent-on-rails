require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'searches/new' do
  it 'renders the "form" partial' do
    stub.proxy(view).render
    mock(view).render 'searches/form'
    render
  end
end
