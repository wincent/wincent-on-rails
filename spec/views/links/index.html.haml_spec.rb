require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe '/links/index.html.haml' do
  include LinksHelper

  before(:each) do
    link_98 = mock_model(Link)
    link_98.should_receive(:uri).and_return('http://example.com/98')
    link_98.should_receive(:permalink).and_return('perma98')
    link_98.should_receive(:click_count).and_return(1)
    link_99 = mock_model(Link)
    link_99.should_receive(:uri).and_return('http://example.com/99')
    link_99.should_receive(:permalink).and_return('perma99')
    link_99.should_receive(:click_count).and_return(1)
    assigns[:links] = [link_98, link_99]
  end

  it 'should render list of links' do
    pending
    render '/links/index.html.haml'
    response.should have_tag('tr>td', 'http://example.com/98', 2)
    response.should have_tag('tr>td', 'http://example.com/99', 2)
    response.should have_tag('tr>td', 1, 2)
  end
end

