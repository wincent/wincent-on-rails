 require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'misc/legal' do
  # use spec suite as a reminder to update copyright year in static page
  it 'should end copyright year range with current year' do
    render
    rendered.should contain(/Copyright 1997-#{Time.now.year} Wincent Colaiuta/)
    rendered.should contain(/Copyright 2007-#{Time.now.year} Wincent Colaiuta/)
  end
end
