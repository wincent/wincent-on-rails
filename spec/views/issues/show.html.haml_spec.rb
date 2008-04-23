require File.dirname(__FILE__) + '/../../spec_helper'

describe '/issues/show' do
  include IssuesHelper

  before do
    assigns[:issue]     = @issue = create_issue
    assigns[:comments]  = []
    assigns[:comment]   = Comment.new
    render '/issues/show'
  end

  it 'should show breadcrumbs' do
    response.should have_tag('div#breadcrumbs', /#{@issue.kind_string} \##{@issue.id}/) do
      with_tag 'a[href=?]', root_path
      with_tag 'a[href=?]', issues_path
    end
  end
end

describe '/issues/show viewed by an administrator' do
  include IssuesHelper

  before do
    assigns[:issue]     = @issue = create_issue
    assigns[:comments]  = []
    assigns[:comment]   = Comment.new
    template.should_receive(:admin?).at_least(:once).and_return(true)
    render '/issues/show'
  end

  it 'should show an edit link' do
    response.should have_tag('a[href=?]', edit_issue_path(@issue))
  end

  it 'should show a destroy link' do
    response.should have_text(/destroy/) # not sure how best to test this, so this is a cheap stand-in for now
  end
end

describe '/issues/show viewed by a normal user' do
  include IssuesHelper

  before do
    assigns[:issue]     = @issue = create_issue
    assigns[:comments]  = []
    assigns[:comment]   = Comment.new
    template.should_receive(:admin?).at_least(:once).and_return(false)
    render '/issues/show'
  end

  it 'should not show an edit link' do
    response.should_not have_tag('a[href=?]', edit_issue_path(@issue))
  end

  it 'should not show a destroy link' do
    response.should_not have_text(/destroy/) # not sure how best to test this, so this is a cheap stand-in for now
  end
end
