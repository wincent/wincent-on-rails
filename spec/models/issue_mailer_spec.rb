require File.dirname(__FILE__) + '/../spec_helper'

describe IssueMailer, 'issue' do
  include ActionController::UrlWriter
  default_url_options[:host] = APP_CONFIG['host']
  default_url_options[:port] = APP_CONFIG['port'] if APP_CONFIG['port'] != 80

  before do
    @issue  = create_issue
    @mail   = IssueMailer.create_new_issue_alert @issue
  end

  it 'should set the subject line' do
    @mail.subject.should =~ /new issue alert/
  end

  it 'should be addressed to the site administrator' do
    @mail.to.length.should == 1
    @mail.to.first.should == APP_CONFIG['admin_email']
  end

  it 'should be from the administrator' do
    @mail.from.length.should == 1
    @mail.from.first.should == APP_CONFIG['admin_email']
  end

  it 'should show "awaiting moderation" where applicable' do
    issue = create_issue :awaiting_moderation => true
    mail    = IssueMailer.create_new_issue_alert issue
    mail.body.should match(/awaiting moderation/)
    mail.body.should_not match(/not awaiting moderation/)
  end

  it 'should show "not awaiting moderation" where applicable' do
    issue = create_issue :awaiting_moderation => false
    mail    = IssueMailer.create_new_issue_alert issue
    mail.body.should match(/not awaiting moderation/)
  end

  it 'should show the issue summary in the body' do
    @mail.body.should match(/#{@issue.summary}/)
  end

  it 'should show the issue description in the body' do
    @mail.body.should match(/#{@issue.description}/)
  end

  it 'should include a link to the administator dashboard' do
    @mail.body.should match(/#{admin_dashboard_url}/)
  end

  it 'should include a link to the issue edit form' do
    @mail.body.should match(/#{edit_issue_url(@issue)}/)
  end
end
