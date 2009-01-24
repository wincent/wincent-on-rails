require File.dirname(__FILE__) + '/../../spec_helper'

describe '/issues/show' do
  include IssuesHelper

  before do
    assigns[:issue]     = @issue = create_issue
    assigns[:comments]  = []
    assigns[:comment]   = Comment.new
  end

  def do_render
    render '/issues/show'
  end

  it 'should show breadcrumbs' do
    do_render
    response.should have_tag('div#breadcrumbs', /#{@issue.kind_string} \##{@issue.id}/) do
      with_tag 'a[href=?]', root_url
      with_tag 'a[href=?]', issues_url
    end
  end

  it 'should advertise an atom feed' do
    template.should_receive(:atom_link).with(@issue)
    do_render
  end
end

describe '/issues/show for a private issue' do
  include IssuesHelper

  before do
    assigns[:issue]     = @issue = create_issue(:public => false)
    assigns[:comments]  = []
    assigns[:comment]   = Comment.new
  end

  it 'should not advertise an atom feed' do
    template.should_not_receive(:atom_link).with(@issue)
    render '/issues/show'
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
    response.should have_tag('a[href=?]', edit_issue_url(@issue))
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
