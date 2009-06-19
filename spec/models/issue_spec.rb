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

describe Issue, 'creation' do
  it 'should default to accepting comments' do
    new_issue.accepts_comments.should == true
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

# :summary, :description, :public, :product_id, :kind
describe Issue, 'accessible attributes' do
  it 'should allow mass-assignment to the summary' do
    new_issue.should allow_mass_assignment_of(:summary => String.random)
  end

  it 'should allow mass-assignment to the description' do
    new_issue.should allow_mass_assignment_of(:description => String.random)
  end

  it 'should allow mass-assignment to the public attribute' do
    new_issue(:public => false).should allow_mass_assignment_of(:public => true)
  end

  it 'should allow mass-assignment to the product_id' do
    new_issue.should allow_mass_assignment_of(:product_id => create_product.id)
  end

  it 'should allow mass-assignment to the kind' do
    new_issue.should allow_mass_assignment_of(:kind => Issue::KIND[:feedback])
  end

  it 'should allow mass-assignment to the "status" attribute' do
    issue = new_issue :status => Issue::STATUS[:closed]
    issue.should allow_mass_assignment_of(:status => Issue::STATUS[:open])
  end
end

describe Issue, 'protected attributes' do
  # don't want non-admin users being able to create or assign tags
  it 'should not allow mass-assignment to the "pending tags" attribute' do
    new_issue.should_not allow_mass_assignment_of(:pending_tags => 'foo bar baz')
  end
end

describe Issue, 'validating the description' do
  it 'should not require it to be present' do
    new_issue(:description => '').should_not fail_validation_for(:description)
  end

  it 'should complain if longer than 128k' do
    long_description = 'x' * (128 * 1024 + 100)
    issue = new_issue(:description => long_description)
    issue.should fail_validation_for(:description)
  end
end

describe Issue, "annotations" do
  before do
    @issue = create_issue
  end

  it 'should not add an annotation to new records' do
    @issue.comments.length.should == 0
  end

  it 'should add an annotation for summary changes' do
    old = @issue.summary
    new = String.random
    @issue.summary = new
    @issue.save
    body = @issue.comments.first.body
    body.should =~ /Summary.*changed:/
    body.should =~ /From:.*#{old}/
    body.should =~ /To:.*#{new}/
  end

  it 'should add an annotation for kind changes' do
    @issue = create_issue :kind => Issue::KIND[:bug]
    @issue.kind = Issue::KIND[:feature_request]
    @issue.save
    body = @issue.comments.first.body
    body.should =~ /Kind.*changed:/
    body.should =~ /From:.*bug/
    body.should =~ /To:.*feature request/
  end

  it 'should add an annotation for status changes' do
    @issue = create_issue :status => Issue::STATUS[:open]
    @issue.status = Issue::STATUS[:closed]
    @issue.save
    body = @issue.comments.first.body
    body.should =~ /Status.*changed:/
    body.should =~ /From:.*open/
    body.should =~ /To:.*closed/
  end

  it 'should add an annotation for public changes' do
    @issue = create_issue :public => true
    @issue.public = false
    @issue.save
    body = @issue.comments.first.body
    body.should =~ /Public.*changed:/
    body.should =~ /From:.*true/
    body.should =~ /To:.*false/
  end

  it 'should add an annotation for product changes' do
    old, new = create_product, create_product
    @issue = create_issue :product_id => old.id
    @issue.product_id = new.id
    @issue.save
    body = @issue.comments.first.body
    body.should =~ /Product.*changed:/
    body.should =~ /From:.*#{old.name}/
    body.should =~ /To:.*#{new.name}/
  end

  it 'should add an annotation for tag changes' do
    @issue.tag 'foo'
    @issue.pending_tags = 'bar'
    @issue.save
    body = @issue.comments.first.body
    body.should =~ /Tags.*changed:/
    body.should =~ /From:.*foo/
    body.should =~ /To:.*bar/
  end

  it 'should collapse multiple annotations into a single comment' do
    # tags: foo -> bar
    @issue.tag 'foo'
    @issue.pending_tags = 'bar'

    # summary: old -> new
    old_summary = @issue.summary
    @issue.summary = new_summary = String.random
    @issue.save
    body = @issue.comments.first.body
    body.should =~ /Summary.*changed:/
    body.should =~ /From:.*#{old_summary}/
    body.should =~ /To:.*#{new_summary}/
    body.should =~ /Tags.*changed:/
    body.should =~ /From:.*foo/
    body.should =~ /To:.*bar/
  end

  it 'should create anonymous annotations for changes made outside of controller actions' do
    # although in practice we never want to make changes outside of the controller
    @issue.summary = String.random
    @issue.save
    @issue.comments.first.user_id.should be_nil
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
