require File.dirname(__FILE__) + '/../spec_helper'
require File.join(File.dirname(__FILE__), '..', 'lib', 'active_record', 'acts', 'shared_taggable_spec')
require File.join(File.dirname(__FILE__), '..', 'lib', 'shared_commentable_spec')

describe Issue do
  before do
    @issue = create_issue
  end

  it 'should be valid' do
    @issue.should be_valid
  end

  # we test a value larger than the default MySQL TEXT size (65535)
  it 'should support description content of over 128K' do
    # make sure the long description survives the round-trip from the db
    length = 128 * 1024
    long_description = 'x' * length
    issue = create_issue :description => long_description
    issue.description.length.should == length
    issue.reload
    issue.description.length.should == length
  end
end

describe Issue, 'acting as commentable' do
  before do
    @commentable = create_issue
  end

  it_should_behave_like 'Commentable'
  it_should_behave_like 'Commentable updating timestamps for comment changes'
end

describe Issue, 'acting as taggable' do
  before do
    @object     = create_issue
    @new_object = new_issue
  end

  it_should_behave_like 'ActiveRecord::Acts::Taggable'
end

describe Issue, 'validating the description' do
  it 'should require it to be present' do
    new_issue(:description => nil).should fail_validation_for(:description)
  end

  it 'should complain if longer than 128k' do
    long_description = 'x' * (128 * 1024 + 100)
    issue = new_issue(:description => long_description)
    issue.should fail_validation_for(:description)
  end
end

describe Issue, '"send_new_issue_alert" method' do
  before do
    @issue = new_issue :user => (create_user :superuser => false)
  end

  it 'should fire after saving new records' do
    @issue.should_receive(:send_new_issue_alert)
    @issue.save
  end

  it 'should not fire after saving an existing record' do
    @issue.save
    @issue.should_not_receive(:send_new_issue_alert)
    @issue.save
  end

  it 'should deliver a new issue alert for normal user issues' do
    IssueMailer.should_receive(:deliver_new_issue_alert).with(@issue)
    @issue.save
  end

  it 'should deliver a new issue alert for anonymous issues' do
    issue = new_issue :user => nil
    IssueMailer.should_receive(:deliver_new_issue_alert).with(issue)
    issue.save
  end

  it 'should not send issue alerts for superuser issues' do
    issue = new_issue :user => (create_user :superuser => true)
    IssueMailer.should_not_receive(:deliver_new_issue_alert)
    issue.save
  end

  it 'should rescue exceptions rather than dying' do
    IssueMailer.should_receive(:deliver_new_issue_alert).and_raise('fatal error!')
    lambda { @issue.save }.should_not raise_error
  end

  it 'should log an error message on failure' do
    IssueMailer.stub!(:deliver_new_issue_alert).and_raise('fatal error!')
    @issue.logger.should_receive(:error)
    @issue.save
  end
end
