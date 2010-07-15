require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Issue do
  before do
    @issue = Issue.make!
  end

  # we test a value larger than the default MySQL TEXT size (65535)
  it 'should support description content of over 128K' do
    # make sure the long description survives the round-trip from the db
    length = 128 * 1024
    long_description = 'x' * length
    issue = Issue.make! :description => long_description
    issue.description.length.should == length
    issue.reload
    issue.description.length.should == length
  end
end

describe Issue, 'creation' do
  it 'should default to accepting comments' do
    Issue.make.accepts_comments.should == true
  end
end

describe Issue, 'acting as commentable' do
  before do
    @commentable = Issue.make!
  end

  it_should_behave_like 'Commentable'
  it_should_behave_like 'Commentable updating timestamps for comment changes'
end

describe Issue, 'acting as taggable' do
  before do
    @object     = Issue.make!
    @new_object = Issue.make
  end

  it_should_behave_like 'ActiveRecord::Acts::Taggable'
end

# :summary, :description, :public, :product_id, :kind
describe Issue, 'accessible attributes' do
  it 'should allow mass-assignment to the summary' do
    Issue.make.should allow_mass_assignment_of(:summary => Sham.random)
  end

  it 'should allow mass-assignment to the description' do
    Issue.make.should allow_mass_assignment_of(:description => Sham.random)
  end

  it 'should allow mass-assignment to the public attribute' do
    Issue.make(:public => false).should allow_mass_assignment_of(:public => true)
  end

  it 'should allow mass-assignment to the product_id' do
    Issue.make.should allow_mass_assignment_of(:product_id => Product.make!.id)
  end

  it 'should allow mass-assignment to the kind' do
    Issue.make.should allow_mass_assignment_of(:kind => Issue::KIND[:feedback])
  end

  it 'should allow mass-assignment to the "status" attribute' do
    issue = Issue.make :status => Issue::STATUS[:closed]
    issue.should allow_mass_assignment_of(:status => Issue::STATUS[:open])
  end
end

describe Issue, 'protected attributes' do
  # don't want non-admin users being able to create or assign tags
  it 'should not allow mass-assignment to the "pending tags" attribute' do
    Issue.make.should_not allow_mass_assignment_of(:pending_tags => 'foo bar baz')
  end
end

describe Issue, 'validating the description' do
  it 'should not require it to be present' do
    Issue.make(:description => '').should_not fail_validation_for(:description)
  end

  it 'should complain if longer than 128k' do
    long_description = 'x' * (128 * 1024 + 100)
    issue = Issue.make(:description => long_description)
    issue.should fail_validation_for(:description)
  end
end

describe Issue, "annotations" do
  before do
    @issue = Issue.make!
  end

  it 'should not add an annotation to new records' do
    @issue.comments.length.should == 0
  end

  it 'should add an annotation for summary changes' do
    old = @issue.summary
    new = Sham.random
    @issue.summary = new
    @issue.save
    body = @issue.comments.first.body
    body.should =~ /Summary.*changed:/
    body.should =~ /From:.*#{old}/
    body.should =~ /To:.*#{new}/
  end

  it 'should add an annotation for kind changes' do
    @issue = Issue.make! :kind => Issue::KIND[:bug]
    @issue.kind = Issue::KIND[:feature_request]
    @issue.save
    body = @issue.comments.first.body
    body.should =~ /Kind.*changed:/
    body.should =~ /From:.*bug/
    body.should =~ /To:.*feature request/
  end

  it 'should add an annotation for status changes' do
    @issue = Issue.make! :status => Issue::STATUS[:open]
    @issue.status = Issue::STATUS[:closed]
    @issue.save
    body = @issue.comments.first.body
    body.should =~ /Status.*changed:/
    body.should =~ /From:.*open/
    body.should =~ /To:.*closed/
  end

  it 'should add an annotation for public changes' do
    @issue = Issue.make! :public => true
    @issue.public = false
    @issue.save
    body = @issue.comments.first.body
    body.should =~ /Public.*changed:/
    body.should =~ /From:.*true/
    body.should =~ /To:.*false/
  end

  it 'should add an annotation for product changes' do
    old, new = Product.make!, Product.make!
    @issue = Issue.make! :product_id => old.id
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
    @issue.summary = new_summary = Sham.random
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
    @issue.summary = Sham.random
    @issue.save
    @issue.comments.first.user_id.should be_nil
  end
end

describe Issue, '"send_new_issue_alert" method' do
  before do
    @issue = Issue.make :user => (User.make! :superuser => false)
  end

  it 'should fire after saving new records' do
    mock(@issue).send_new_issue_alert
    @issue.save
  end

  it 'should not fire after saving an existing record' do
    @issue.save
    do_not_allow(@issue).send_new_issue_alert
    @issue.save
  end

  it 'should deliver a new issue alert for normal user issues' do
    mock(IssueMailer).new_issue_alert(@issue).stub!.deliver
    @issue.save
  end

  it 'should deliver a new issue alert for anonymous issues' do
    issue = Issue.make :user => nil
    mock(IssueMailer).new_issue_alert(issue).stub!.deliver
    issue.save
  end

  it 'should not send issue alerts for superuser issues' do
    issue = Issue.make :user => (User.make! :superuser => true)
    do_not_allow(IssueMailer).new_issue_alert
    issue.save
  end

  it 'should rescue exceptions rather than dying' do
    mock(IssueMailer).new_issue_alert(@issue) { raise 'fatal error!' }
    lambda { @issue.save }.should_not raise_error
  end

  it 'should log an error message on failure' do
    stub(IssueMailer).new_issue_alert(@issue) { raise 'fatal error!' }
    mock(@issue.logger).error(/fatal error!/)
    @issue.save
  end
end
