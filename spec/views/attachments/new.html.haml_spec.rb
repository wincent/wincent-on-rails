require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe '/attachments/new' do
  before do
    render 'attachments/new'
  end

  it 'should say "Upload"' do
    response.should have_text(/Upload/)
  end
end
