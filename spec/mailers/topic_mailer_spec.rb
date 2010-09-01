require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe TopicMailer do
  describe 'new topic alert' do
    before do
      @topic  = Topic.make!
      @mail   = TopicMailer.new_topic_alert @topic
    end

    it 'has content-type "text/plain"' do
      @mail.content_type.should =~ %r{text/plain} # ignore charset
    end

    it 'sets the subject line' do
      @mail.subject.should =~ /new topic alert/
    end

    it 'is addressed to the site administrator' do
      @mail.to.length.should == 1
      @mail.to.first.should == APP_CONFIG['admin_email']
    end

    it 'is from the support address' do
      @mail.from.length.should == 1
      @mail.from.first.should == APP_CONFIG['support_email']
    end

    it 'shows "awaiting moderation" where applicable' do
      topic = Topic.make! :awaiting_moderation => true
      mail    = TopicMailer.new_topic_alert topic
      mail.body.should match(/awaiting moderation/)
      mail.body.should_not match(/not awaiting moderation/)
    end

    it 'shows "not awaiting moderation" where applicable' do
      topic = Topic.make! :awaiting_moderation => false
      mail    = TopicMailer.new_topic_alert topic
      mail.body.should match(/not awaiting moderation/)
    end

    it 'shows the topic title in the body' do
      @mail.body.should match(/#{@topic.title}/)
    end

    it 'shows the topic body in the body' do
      @mail.body.should match(/#{@topic.body}/)
    end

    it 'includes a link to the administator dashboard' do
      @mail.body.should match(/#{admin_dashboard_url}/)
    end

    it 'includes a link to the topic edit form' do
      @mail.body.should match(/#{edit_forum_topic_url(@topic.forum, @topic)}/)
    end

    it 'includes "support@wincent.com" in the Message-ID header' do
      @mail.header['message-id'].to_s.should =~ %r{\A<.+support@wincent.com>\z}
    end

    it 'includes a "return-path" header containing "support@wincent.com"' do
      # will be used as "Envelope from" address
      @mail.header['return-path'].to_s.should =~ /#{Regexp.escape APP_CONFIG['support_email']}/
    end

    it 'creates a corresponding Message object' do
      message = Message.find_by_message_id_header(@mail.header['message-id'].to_s)
      message.related.should == @topic
    end
  end
end
