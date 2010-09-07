require 'spec_helper'

# TODO: add some worthwhile specs here, these don't even confirm that the
# template even renders anything (had to add a "p" statement to check it)
describe 'posts/index.atom.builder' do
  it 'handles no posts' do
    @posts = []
    lambda { render }.should_not raise_error
  end
end
