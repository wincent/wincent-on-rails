require 'spec_helper'

describe 'admin/issues/index' do
  before do
    @issue1 = Issue.make!
    @issue2 = Issue.make!
    @issues = [@issue1, @issue2]
  end

  it 'has an "all issues" link' do
    render
    rendered.should have_link('public issues index', href: issues_path)
  end

  it 'has a "refresh" link' do
    render
    rendered.should have_link('refresh', href: admin_issues_path)
  end

  it 'has a "destroy" button for each issue' do
    mock(view).button_to_destroy_model(@issue1, remote: true)
    mock(view).button_to_destroy_model(@issue2, remote: true)
    render
  end

  it 'has a "ham" button for each issue' do
    mock(view).button_to_moderate_issue_as_ham(@issue1)
    mock(view).button_to_moderate_issue_as_ham(@issue2)
    render
  end
end
