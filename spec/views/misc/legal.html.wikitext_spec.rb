 require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe '/misc/legal' do
  def do_render
    render '/misc/legal'
  end

  # use spec suite as a reminder to update copyright year in static page
  it 'should end copyright year range with current year' do
    do_render
    response.should have_text(/Copyright 1997-#{Time.now.year} Wincent Colaiuta/)
    response.should have_text(/Copyright 2007-#{Time.now.year} Wincent Colaiuta/)
  end
end
