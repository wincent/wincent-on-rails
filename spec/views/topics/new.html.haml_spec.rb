require 'spec_helper'

describe 'topics/new' do
  let(:forum) { Forum.make! }
  let(:topic) { Topic.make :forum => forum }

  context 'viewed as anonymous user' do
    before do
      stub(view).logged_in? { false }
      stub(view).admin? { false }
      @forum = forum
      @topic = topic
      render
    end

    # was a bug (was only showing for admin user)
    it 'has a submit button' do
      rendered.should have_css('input[type=submit]')
    end
  end
end
