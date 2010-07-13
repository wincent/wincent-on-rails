require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'links/new' do
  before do
    @link = Link.make
  end

  it 'renders new form' do
    render
    rendered.should have_selector('form[method=post]', :action => links_path) do |form|
      form.should have_selector('input#link_uri', :name => 'link[uri]')
      form.should have_selector('input#link_permalink', :name => 'link[permalink]')
    end
  end
end
