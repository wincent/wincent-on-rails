require 'spec_helper'

describe 'tags/show' do
  before do
    @tag = Tag.make!
    @taggables = OpenStruct.new
  end

  it 'has an "all tags" link' do
    render
    rendered.should have_css('.links a[href="/tags"]')
  end

  it 'has a "tag search" link' do
    render
    rendered.should have_css('.links a[href="/tags/search"]')
  end
end
