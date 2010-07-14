require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'attachments/new' do
  it 'says "Upload"' do
    render
    rendered.should contain(/Upload/)
  end
end
