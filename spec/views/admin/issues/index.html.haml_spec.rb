require File.expand_path('../../../spec_helper', File.dirname(__FILE__))

describe 'admin/issues/index' do
  before do
    @issue1, @issue2 = Issue.make!, Issue.make!
    @issues = [@issue1, @issue2]
  end

  it 'has an "all issues" link' do
    render
    rendered.should have_selector('div.links a', :href => issues_path)
  end

  it 'has a "refresh" link' do
    render
    rendered.should have_selector('div.links a', :href => admin_issues_path)
  end

  it 'has a "destroy" button for each issue' do
    mock(view).button_to_destroy_issue(@issue1)
    mock(view).button_to_destroy_issue(@issue2)
    render
  end

  it 'has a "ham" button for each issue' do
    mock(view).button_to_moderate_issue_as_ham(@issue1)
    mock(view).button_to_moderate_issue_as_ham(@issue2)
    render
  end
end
