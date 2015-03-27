require 'spec_helper'

describe IssueObserver do
  describe 'sending a new issue alert' do
    let(:user)      { User.make! :superuser => false }
    let(:issue)     { Issue.make :user => user }

    it 'delivers an alert after saving a new issue' do
      mock(IssueMailer).new_issue_alert(issue).stub!.deliver_now
      issue.save
    end

    it 'does not deliver an alert after re-saving an existing record' do
      issue.save
      do_not_allow(IssueMailer).new_issue_alert
      issue.save
    end

    it 'delivers an alert for anonymous issues' do
      issue = Issue.make :user => nil
      mock(IssueMailer).new_issue_alert(issue).stub!.deliver_now
      issue.save
    end

    it 'does not deliver an alert for superuser issues' do
      issue = Issue.make :user => (User.make! :superuser => true)
      do_not_allow(IssueMailer).new_issue_alert
      issue.save
    end

    it 'rescues exceptions rather than dying' do
      mock(IssueMailer).new_issue_alert(issue) { raise 'fatal error!' }
      lambda { issue.save }.should_not raise_error
    end

    it 'logs an error message on failure' do
      mock(IssueMailer).new_issue_alert(issue) { raise 'fatal error!' }
      mock(Rails.logger).error(/fatal error!/)
      issue.save
    end
  end

  describe 'annotations' do
    let(:issue) { Issue.make! }

    it 'does not add an annotation to new records' do
      issue.comments.length.should == 0
    end

    it 'adds an annotation for summary changes' do
      old = issue.summary
      new = Sham.random
      issue.summary = new
      issue.save
      body = issue.comments.first.body
      body.should =~ /Summary.*changed:/
      body.should =~ /From:.*#{old}/
      body.should =~ /To:.*#{new}/
    end

    it 'adds an annotation for kind changes' do
      issue = Issue.make! :kind => Issue::KIND[:bug]
      issue.kind = Issue::KIND[:feature_request]
      issue.save
      body = issue.comments.first.body
      body.should =~ /Kind.*changed:/
      body.should =~ /From:.*bug/
      body.should =~ /To:.*feature request/
    end

    it 'adds an annotation for status changes' do
      issue = Issue.make! :status => Issue::STATUS[:open]
      issue.status = Issue::STATUS[:closed]
      issue.save
      body = issue.comments.first.body
      body.should =~ /Status.*changed:/
      body.should =~ /From:.*open/
      body.should =~ /To:.*closed/
    end

    it 'adds an annotation for public changes' do
      issue = Issue.make! :public => true
      issue.public = false
      issue.save
      body = issue.comments.first.body
      body.should =~ /Public.*changed:/
      body.should =~ /From:.*true/
      body.should =~ /To:.*false/
    end

    it 'adds an annotation for product changes' do
      old, new = Product.make!, Product.make!
      issue = Issue.make! :product_id => old.id
      issue.product_id = new.id
      issue.save
      body = issue.comments.first.body
      body.should =~ /Product.*changed:/
      body.should =~ /From:.*#{old.name}/
      body.should =~ /To:.*#{new.name}/
    end

    it 'adds an annotation for tag changes' do
      issue.tag 'foo'
      issue.pending_tags = 'bar'
      issue.save
      body = issue.comments.first.body
      body.should =~ /Tags.*changed:/
      body.should =~ /From:.*foo/
      body.should =~ /To:.*bar/
    end

    it 'does not add an annotation for description changes' do
      issue.description = "fixed user's non-wikitext markup"
      issue.save
      issue.comments.should be_empty
    end

    it 'collapses multiple annotations into a single comment' do
      # tags: foo -> bar
      issue.tag 'foo'
      issue.pending_tags = 'bar'

      # summary: old -> new
      old_summary = issue.summary
      issue.summary = new_summary = Sham.random
      issue.save
      body = issue.comments.first.body
      body.should =~ /Summary.*changed:/
      body.should =~ /From:.*#{old_summary}/
      body.should =~ /To:.*#{new_summary}/
      body.should =~ /Tags.*changed:/
      body.should =~ /From:.*foo/
      body.should =~ /To:.*bar/
    end

    it 'creates anonymous annotations for changes made outside of controller actions' do
      # although in practice we never want to make changes outside of the controller
      issue.summary = Sham.random
      issue.save
      issue.comments.first.user_id.should be_nil
    end

    describe 'moderation' do
      let(:issue) { Issue.make! :awaiting_moderation => true }

      it 'produces no annotation' do
        issue.moderate_as_ham!
        issue.comments.should be_empty
      end
    end
  end
end
