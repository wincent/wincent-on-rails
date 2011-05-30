require 'spec_helper'

describe IssueObserver do
  let(:user)      { User.make! :superuser => false }
  let(:issue)     { Issue.make :user => user }

  describe 'sending a new issue alert' do
    it 'delivers an alert after saving a new issue' do
      mock(IssueMailer).new_issue_alert(issue).stub!.deliver
      issue.save
    end

    it 'does not deliver an alert after re-saving an existing record' do
      issue.save
      do_not_allow(IssueMailer).new_issue_alert
      issue.save
    end

    it 'delivers an alert for anonymous issues' do
      issue = Issue.make :user => nil
      mock(IssueMailer).new_issue_alert(issue).stub!.deliver
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
end
