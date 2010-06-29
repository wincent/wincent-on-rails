require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe TopicMailer, 'topic' do
  default_url_options[:host] = APP_CONFIG['host']
  default_url_options[:port] = APP_CONFIG['port'] if APP_CONFIG['port'] != 80 and APP_CONFIG['port'] != 443

  before do
    @topic  = create_topic
    @mail   = TopicMailer.create_new_topic_alert @topic
  end

  it 'should set the subject line' do
    @mail.subject.should =~ /new topic alert/
  end

  it 'should be addressed to the site administrator' do
    @mail.to.length.should == 1
    @mail.to.first.should == APP_CONFIG['admin_email']
  end

  it 'should be from the support address' do
    @mail.from.length.should == 1
    @mail.from.first.should == APP_CONFIG['support_email']
  end

  it 'should show "awaiting moderation" where applicable' do
    topic = create_topic :awaiting_moderation => true
    mail    = TopicMailer.create_new_topic_alert topic
    mail.body.should match(/awaiting moderation/)
    mail.body.should_not match(/not awaiting moderation/)
  end

  it 'should show "not awaiting moderation" where applicable' do
    topic = create_topic :awaiting_moderation => false
    mail    = TopicMailer.create_new_topic_alert topic
    mail.body.should match(/not awaiting moderation/)
  end

  it 'should show the topic title in the body' do
    @mail.body.should match(/#{@topic.title}/)
  end

  it 'should show the topic body in the body' do
    @mail.body.should match(/#{@topic.body}/)
  end

  it 'should include a link to the administator dashboard' do
    @mail.body.should match(/#{admin_dashboard_url}/)
  end

  it 'should include a link to the topic edit form' do
    @mail.body.should match(/#{edit_forum_topic_url(@topic.forum, @topic)}/)
  end

  it 'should include "support@wincent.com" in the Message-ID header' do
    @mail.header['message-id'].to_s.should =~ %r{\A<.+support@wincent.com>\z}
  end

  it 'should include a "return-path" header containing "support@wincent.com"' do
    # will be used as "Envelope from" address
    @mail.header['return-path'].to_s.should =~ /#{Regexp.escape APP_CONFIG['support_email']}/
  end

  it 'should create a corresponding Message object' do
    message = Message.find_by_message_id_header(@mail.header['message-id'].to_s)
    message.related.should == @topic
  end
end
