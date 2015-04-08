 require 'spec_helper'

describe 'misc/legal' do
  # use spec suite as a reminder to update copyright year in static page
  it 'should end copyright year range with current year' do
    render
    expect(rendered).to have_content("Copyright 1997-#{Time.now.year} Greg Hurrell")
    expect(rendered).to have_content("Copyright 2007-#{Time.now.year} Greg Hurrell")
  end
end
