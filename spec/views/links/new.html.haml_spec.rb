require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe '/links/new.html.haml' do
  include LinksHelper

  before(:each) do
    @link = mock_model(Link)
    @link.stub!(:new_record?).and_return(true)
    @link.stub!(:uri).and_return(FR::random_string)
    @link.stub!(:permalink).and_return(FR::random_string)
    @link.stub!(:click_count).and_return(1)
    assigns[:link] = @link
  end

  it 'should render new form' do
    render '/links/new.html.haml'

    response.should have_tag('form[action=?][method=post]', links_path) do
      with_tag('input#link_uri[name=?]', 'link[uri]')
      with_tag('input#link_permalink[name=?]', 'link[permalink]')
    end
  end
end


