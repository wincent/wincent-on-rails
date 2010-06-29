require File.expand_path('../spec_helper', File.dirname(__FILE__))

def sample_email name
  path = File.dirname(__FILE__) + '/../fixtures/mail/' + name
  IO.read(path)
end

describe SupportMailer do
  it 'should process incoming support requests'

  context 'incoming text/plain email' do
    before do
      @email = <<-EMAIL
Return-Path: <win@wincent.com>
Received: from murder ([unix socket])
         (authenticated user=support_wincent_com bits=0)
         by wincent1.inetu.net (Cyrus v2.3.7-Invoca-RPM-2.3.7-2.el5) with LMTPA;
         Sat, 14 Feb 2009 07:47:59 -0500
X-Sieve: CMU Sieve 2.3
X-Spam-Checker-Version: SpamAssassin 3.2.5 (2008-06-10) on wincent1.inetu.net
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=10.0 tests=ALL_TRUSTED autolearn=ham
        version=3.2.5
Received: from cuzco.lan (54.pool85-53-5.dynamic.orange.es [85.53.5.54])
        (authenticated bits=0)
        by wincent1.inetu.net (8.13.8/8.13.8) with ESMTP id n1EClvSd008356
        (version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NO)
        for <support@wincent.com>; Sat, 14 Feb 2009 07:47:58 -0500
Message-Id: <6DE23D11-7212-484C-899B-1E2F692D0D92@wincent.com>
From: Wincent Colaiuta <win@wincent.com>
To: support@wincent.com
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0 (Apple Message framework v930.3)
Subject: Can't print
Date: Sat, 14 Feb 2009 13:47:56 +0100
X-Mailer: Apple Mail (2.930.3)

Can you help me?
Wincent

EMAIL
      @message_id = '6DE23D11-7212-484C-899B-1E2F692D0D92@wincent.com'
    end

    it 'should accept text/plain emails' do
      lambda { SupportMailer.receive @email }.should_not raise_error
    end

    it 'should create a Message object' do
      lambda {
        SupportMailer.receive @email
      }.should change {
        # check for this specific message because a secondary message gets
        # sent out when we create a new ticket in the issue tracker
        Message.where(:message_id_header => @message_id).count
      }.by(1)
    end

    it 'should should set the attribtues on the Message object' do
      SupportMailer.receive @email
      message = Message.where(:message_id_header => @message_id).first
      message.subject_header.should == "Can't print"
      message.in_reply_to_header.should be_nil
      message.body.should =~ /Can you help me\?/
      message.to_header.should == 'support@wincent.com'
      message.from_header.should == 'win@wincent.com'
    end

    it 'should create an Issue object' do
      lambda {
        SupportMailer.receive @email
      }.should change(Issue, :count).by(1)
    end

    it 'should set the issue summary to the email subject header' do
      SupportMailer.receive @email
      Issue.last.summary.should == "Can't print"
    end

    it 'should set the issue description to the email body' do
      SupportMailer.receive @email
      Issue.last.description.should =~ /Can you help me\?/
    end

    # TODO: change this; we'll create a non-confirmed user account for such users
    it 'should leave the issue as anonymous for emails from unregistered users' do
      SupportMailer.receive @email
      Issue.last.user.should be_nil
    end

    # BUG: possible security issue here because emails are so easily spoofed
    it 'should assign issue ownership to the user for emails from registered users' do
      email = Email.make! :address => 'win@wincent.com'
      SupportMailer.receive @email
      Issue.last.user.should == email.user
    end

    it 'should set the issue as the "related" model for the Message record' do
      SupportMailer.receive @email
      message = Message.where(:message_id_header => @message_id).first
      message.related.should == Issue.last
    end
  end
end

describe SupportMailer, 'regressions' do
  it 'should handle incoming mails without valid "To" headers' do
    pending 'Under Rails 3 bad emails cause an exception before we even reach our receive() method'
    lambda {
      SupportMailer.receive sample_email('real/dodgy-to-header')
    }.should_not raise_error
  end

  it 'should handle incoming mails without "To" headers' do
    pending 'Under Rails 3 bad emails cause an exception before we even reach our receive() method'
    lambda {
      SupportMailer.receive sample_email('fake/no-to-header')
    }.should_not raise_error
  end

  it 'should handle incoming mails without valid "From" headers' do
    pending 'Under Rails 3 bad emails cause an exception before we even reach our receive() method'
    lambda {
      SupportMailer.receive sample_email('fake/dodgy-from-header')
    }.should_not raise_error
  end

  it 'should handle incoming mails without "From" headers' do
    pending 'Under Rails 3 bad emails cause an exception before we even reach our receive() method'
    lambda {
      SupportMailer.receive sample_email('fake/no-from-header')
    }.should_not raise_error
  end

  it 'should keep the new_issue_from_message method private' do
    lambda {
      SupportMailer.new_issue_from_message
    }.should raise_error(NoMethodError)
  end
end
