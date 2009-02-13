require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'public/404.html' do
  # use spec suite as a reminder to update copyright year in static page
  it 'should end copyright year range with current year' do
    path = File.join(File.dirname(__FILE__), '..', '..', 'public', '404.html')
    page = File.new(path).read
    page.should =~ /Copyright &copy; 1997-#{Time.now.year}/
  end
end

