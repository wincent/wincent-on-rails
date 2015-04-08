require 'spec_helper'

describe 'posts/index' do
  before do
    @posts  = [Post.make!]
  end

  # was a bug
  it 'does not have nested <p> tags' do
    render
    expect(rendered).not_to match(/<p>\w*<p>/)
  end
end
