require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'tags/index' do
  before do
    @tags = [Tag.make!]
  end

  it 'should have a "tag search" link' do
    render
    rendered.should have_selector('.links a[href="/tags/search"]')
  end
end
