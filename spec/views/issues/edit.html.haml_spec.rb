require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'issues/edit' do
  before do
    stub(view).render 'shared/error_messages', anything
    stub(view).render 'issues/form', anything
    stub.proxy(view).render
    @issue = Issue.make!
  end

  it 'should have a div for the issue' do
    render
    rendered.should have_selector("\#issue_#{@issue.id}")
  end

  it 'should render the form partial' do
    mock(view).render 'issues/form', anything
    render
  end

  it 'should have a "show" link' do
    render
    rendered.should have_selector('.links a', :href => issue_path(@issue))
  end

  it 'should have a destroy button' do
    mock(view).button_to_destroy_issue @issue
    render
  end

  it 'should have a ham button if the issue is awaiting moderation' do
    @issue = Issue.make! :awaiting_moderation => true
    mock(view).button_to_moderate_issue_as_ham @issue
    render
  end

  # was a bug
  it 'should not have a ham button if the issue is not awaiting moderation' do
    @issue = Issue.make! :awaiting_moderation => false
    do_not_allow(view).button_to_moderate_issue_as_ham
    render
  end

  it 'should have a link back to the list of issues awaiting moderation' do
    render
    rendered.should have_selector('.links a', :href => admin_issues_path)
  end

  it 'should have a link to the list of public isues' do
    render
    rendered.should have_selector('.links a', :href => issues_path)
  end
end
