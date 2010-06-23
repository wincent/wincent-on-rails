require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe '/attachments/new' do
  before do
    render 'attachments/new'
  end

  it 'should say "Upload"' do
    response.should have_text(/Upload/)
  end
end
