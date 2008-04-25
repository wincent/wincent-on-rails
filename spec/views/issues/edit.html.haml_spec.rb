require File.dirname(__FILE__) + '/../../spec_helper'

describe '/issues/edit' do
  include IssuesHelper

  before do
    assigns[:issue] = @issue = create_issue
  end

  def do_render
    render '/issues/edit'
  end

  it 'should have a div for the issue' do
    do_render
    response.should have_tag("\#issue_#{@issue.id}")
  end

  it 'should render the form partial' do
    form = mock('form', :null_object => true)
    template.stub!(:form_for).and_yield(form)
    template.expect_render :partial => 'issues/form', :locals => { :f => form }
    do_render
  end

  it 'should have a "show" link' do
    do_render
    response.should have_tag('.links') do
      with_tag 'a[href=?]', issue_path(@issue)
    end
  end

  it 'should have a destroy button' do
    template.should_receive(:button_to_destroy_issue).with(@issue)
    do_render
  end

  it 'should have a spam button' do
    template.should_receive(:button_to_moderate_issue_as_spam).with(@issue)
    do_render
  end

  it 'should have a ham button' do
    template.should_receive(:button_to_moderate_issue_as_ham).with(@issue)
    do_render
  end

  it 'should have a link back to the list of issues awaiting moderation' do
    do_render
    response.should have_tag('.links') do
      with_tag 'a[href=?]', admin_issues_path
    end
  end

  it 'should have a link to the list of public isues' do
    do_render
    response.should have_tag('.links') do
      with_tag 'a[href=?]', issues_path
    end
  end
end
