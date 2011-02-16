require 'spec_helper'

describe CommentsHelper do
  describe '#link_to_parent' do
    context 'snippet parent' do
      let(:parent) { Snippet.make! }

      it 'returns the snippet path' do
        link_to_parent(parent).should =~ %r{href="#{snippet_path(parent)}"}
      end
    end
  end
end
