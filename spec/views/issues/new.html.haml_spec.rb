require 'spec_helper'

describe 'issues/new' do
  context 'viewed as anonymous user' do
    before do
      stub(view).logged_in? { false }
      @issue = Issue.make
      render
    end

    # was a bug, fixed in 3bfe4d4
    it 'points out that anonymous tickets must be public' do
      rendered.should contain(/ticket must be public because you are posting anonymously/)
    end
  end

  context 'viewed as logged in user' do
    before do
      user = User.make!
      stub(view).current_user { user }
      stub(view).logged_in? { true }
      @issue = Issue.make
      render
    end

    # was a bug, fixed in 3bfe4d4
    it 'does not point out that anonymous tickets must be public' do
      rendered.should_not contain(/ticket must be public because you are posting anonymously/)
    end
  end
end
