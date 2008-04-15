require File.dirname(__FILE__) + '/../../spec_helper'

describe '/issues/new viewed as anonymous user' do
  include IssuesHelper

  before do
    template.should_receive(:logged_in?).at_least(1).and_return(false)
    assigns[:issue] = @issue = new_issue
    render '/issues/new'
  end

  # was a bug, fixed in 3bfe4d4
  it 'should point out that anonymous tickets must be public' do
    response.should have_text(/ticket must be public because you are posting anonymously/)
  end
end

describe '/issues/new viewed as logged in user' do
  include IssuesHelper

  before do
    template.should_receive(:logged_in?).at_least(1).and_return(true)
    template.stub!(:current_user).and_return(create_user)
    assigns[:issue] = @issue = new_issue
    render '/issues/new'
  end

  # was a bug, fixed in 3bfe4d4
  it 'should not point out that anonymous tickets must be public' do
    response.should_not have_text(/ticket must be public because you are posting anonymously/)
  end
end
