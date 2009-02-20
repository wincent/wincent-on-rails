require File.dirname(__FILE__) + '/../spec_helper'

describe CommentMailer, 'comment' do
  include ActionController::UrlWriter
  default_url_options[:host] = APP_CONFIG['host']
  default_url_options[:port] = APP_CONFIG['port'] if APP_CONFIG['port'] != 80

  before do
    @comment  = create_comment
    @mail     = CommentMailer.create_new_comment_alert @comment
  end

  it 'should set the subject line' do
    @mail.subject.should =~ /new comment alert/
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
    comment = create_comment :awaiting_moderation => true
    mail    = CommentMailer.create_new_comment_alert comment
    mail.body.should match(/awaiting moderation/)
    mail.body.should_not match(/not awaiting moderation/)
  end

  it 'should show "not awaiting moderation" where applicable' do
    comment = create_comment :awaiting_moderation => false
    mail    = CommentMailer.create_new_comment_alert comment
    mail.body.should match(/not awaiting moderation/)
  end

  it 'should show the comment body in the body' do
    @mail.body.should match(/#{@comment.body}/)
  end

  it 'should include a link to the administator dashboard' do
    @mail.body.should match(/#{admin_dashboard_url}/)
  end

  it 'should include a link to the comment edit form' do
    @mail.body.should match(/#{edit_comment_url(@comment)}/)
  end

  it 'should include "@wincent.com" in the Message-ID header' do
    @mail.header['message-id'].to_s.should =~ %r{@wincent.com}
  end

  it 'should create a corresponding Message object' do
    message = Message.find_by_message_id_header(@mail.header['message-id'].to_s)
    message.related.should == @comment
  end
end
