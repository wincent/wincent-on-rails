require File.dirname(__FILE__) + '/../../../spec_helper'

describe '/admin/issues/index' do
  before do
    @issue1, @issue2 = create_issue, create_issue
    assigns[:issues] = [@issue1, @issue2]
  end

  def do_render
    render '/admin/issues/index'
  end

  it 'should have an "all issues" link' do
    do_render
    response.should have_tag('div.links') do
      with_tag 'a[href=?]', issues_url
    end
  end

  it 'should have a "refresh" link' do
    do_render
    response.should have_tag('div.links') do
      with_tag 'a[href=?]', admin_issues_url
    end
  end

  it 'should have a "destroy" button for each issue' do
    template.should_receive(:button_to_destroy_issue).with(@issue1)
    template.should_receive(:button_to_destroy_issue).with(@issue2)
    do_render
  end

  it 'should have a "spam" button for each issue' do
    template.should_receive(:button_to_moderate_issue_as_spam).with(@issue1)
    template.should_receive(:button_to_moderate_issue_as_spam).with(@issue2)
    do_render
  end

  it 'should have a "ham" button for each issue' do
    template.should_receive(:button_to_moderate_issue_as_ham).with(@issue1)
    template.should_receive(:button_to_moderate_issue_as_ham).with(@issue2)
    do_render
  end
end
