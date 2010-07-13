require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'tags/show' do
  before do
    @tag = Tag.make!
    @taggables = OpenStruct.new
  end

  it 'has an "all tags" link' do
    render
    rendered.should have_selector('.links a[href="/tags"]')
  end

  it 'has a "tag search" link' do
    render
    rendered.should have_selector('.links a[href="/tags/search"]')
  end
end
