require 'spec_helper'

describe 'articles/index.atom.builder' do
  it 'handles no articles' do
    @articles = []
    lambda { render }.should_not raise_error
  end
end
