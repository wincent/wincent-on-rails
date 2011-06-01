require 'spec_helper'

describe 'tags/index' do
  before do
    @tags = [Tag.make!]
  end

  it 'should have a "tag search" link' do
    render
    rendered.should have_css('.links a[href="/tags/search"]')
  end
end
