require File.expand_path('../../spec_helper', File.dirname(__FILE__))

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
    template.should_receive :render, :partial => 'issues/form', :locals => { :f => form }
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

  it 'should have a ham button if the issue is awaiting moderation' do
    assigns[:issue] = @issue = create_issue(:awaiting_moderation => true)
    template.should_receive(:button_to_moderate_issue_as_ham).with(@issue)
    do_render
  end

  # was a bug
  it 'should not have a ham button if the issue is not awaiting moderation' do
    assigns[:issue] = @issue = create_issue(:awaiting_moderation => false)
    template.should_not_receive(:button_to_moderate_issue_as_ham)
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
