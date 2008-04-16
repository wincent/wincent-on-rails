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
