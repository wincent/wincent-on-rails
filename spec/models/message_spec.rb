require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Message do
  it 'should treat all fields as optional' do
    Message.create.should be_valid
  end

  describe 'incoming attribute' do
    it 'should default to true' do
      Message.create.incoming.should == true
    end
  end

  describe 'message_id_header attribute' do
    it 'should be auto-populated if needed for outgoing mails' do
      # no message_id_header supplied
      message = Message.create :incoming => false
      message.message_id_header.should match(/\A<.+@.+>\z/)

      # explicit message_id_header supplied
      message = Message.create :incoming => false, :message_id_header => 'foo'
      message.message_id_header.should == 'foo'
    end

    it 'should not be auto-populated for incoming mails' do
      # no message_id_header supplied
      message = Message.create :incoming => true
      message.message_id_header.should be_nil

      # explicit message_id_header supplied
      message = Message.create :incoming => true, :message_id_header => 'foo'
      message.message_id_header.should == 'foo'
    end
  end

  describe 'message_id class method' do
    it 'should produce unique message IDs' do
      ids = Array.new(1000) { Message.message_id }
      ids.uniq.count.should == 1000
    end

    it 'should follow the "standard" message ID format' do
      Message.message_id.should match(/\A<.+@.+>\z/)
    end
  end
end

# :related, :message_id_header, :to_header, :from_header, :subject_header,
# :in_reply_to_header, :body, :incoming
describe Message, 'accessible attributes' do
  it 'should allow mass-assignment of the related model' do
    Message.make.should allow_mass_assignment_of(:related => Issue.make!)
  end

  it 'should allow mass-assignment of the message ID header' do
    Message.make.should allow_mass_assignment_of(:message_id_header => '<foo@example.com>')
  end

  it 'should allow mass-assignment of the to header' do
    Message.make.should allow_mass_assignment_of(:to_header => 'recipient@example.org')
  end

  it 'should allow mass-assignment of the from header' do
    Message.make.should allow_mass_assignment_of(:from_header => 'sender@example.net')
  end
  it 'should allow mass-assignment of the subject header' do
    Message.make.should allow_mass_assignment_of(:subject_header => 'viagra')
  end

  it 'should allow mass-assignment of the in-reply-to header' do
    Message.make.should allow_mass_assignment_of(:in_reply_to_header => '<msg@example.net>')
  end

  it 'should allow mass-assignment of the body' do
    Message.make.should allow_mass_assignment_of(:body => 'bar')
  end

  it 'should allow mass-assignment of the incoming attribute' do
    Message.make(:incoming => false).should allow_mass_assignment_of(:incoming => true)
  end
end

# :created_at, :updated_at
describe Message, 'protected attributes' do
  it 'should deny mass-assignment of the created at attribute' do
    Message.make!.should_not allow_mass_assignment_of(:created_at => 10.days.ago)
  end

  it 'should deny mass-assignment of the updated at attribute' do
    Message.make!.should_not allow_mass_assignment_of(:updated_at => 2.weeks.ago)
  end
end
