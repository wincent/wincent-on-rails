require 'spec_helper'

describe Message do
  describe '#related_id' do
    it 'defaults to nil' do
      expect(Message.new.related_id).to be_nil
    end
  end

  describe '#related_type' do
    it 'defaults to nil' do
      expect(Message.new.related_type).to be_nil
    end
  end

  describe '#message_id_header' do
    it 'defaults to nil' do
      expect(Message.new.message_id_header).to be_nil
    end
  end

  describe '#to_header' do
    it 'defaults to nil' do
      expect(Message.new.to_header).to be_nil
    end
  end

  describe '#from_header' do
    it 'defaults to nil' do
      expect(Message.new.from_header).to be_nil
    end
  end

  describe '#subject_header' do
    it 'defaults to nil' do
      expect(Message.new.subject_header).to be_nil
    end
  end

  describe '#in_reply_to_header' do
    it 'defaults to nil' do
      expect(Message.new.in_reply_to_header).to be_nil
    end
  end

  describe '#body' do
    it 'defaults to nil' do
      expect(Message.new.body).to be_nil
    end
  end

  describe '#incoming' do
    it 'defaults to true' do
      expect(Message.new.incoming).to eq(true)
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      expect(Message.new.created_at).to be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      expect(Message.new.updated_at).to be_nil
    end
  end

  it 'should treat all fields as optional' do
    expect(Message.create).to be_valid
  end

  describe 'incoming attribute' do
    it 'should default to true' do
      expect(Message.create.incoming).to eq(true)
    end
  end

  describe 'message_id_header attribute' do
    it 'should be auto-populated if needed for outgoing mails' do
      # no message_id_header supplied
      message = Message.create :incoming => false
      expect(message.message_id_header).to match(/\A<.+@.+>\z/)

      # explicit message_id_header supplied
      message = Message.create :incoming => false, :message_id_header => 'foo'
      expect(message.message_id_header).to eq('foo')
    end

    it 'should not be auto-populated for incoming mails' do
      # no message_id_header supplied
      message = Message.create :incoming => true
      expect(message.message_id_header).to be_nil

      # explicit message_id_header supplied
      message = Message.create :incoming => true, :message_id_header => 'foo'
      expect(message.message_id_header).to eq('foo')
    end
  end

  describe 'message_id class method' do
    it 'should produce unique message IDs' do
      ids = Array.new(1000) { Message.message_id }
      expect(ids.uniq.count).to eq(1000)
    end

    it 'should follow the "standard" message ID format' do
      expect(Message.message_id).to match(/\A<.+@.+>\z/)
    end
  end
end

# :related, :message_id_header, :to_header, :from_header, :subject_header,
# :in_reply_to_header, :body, :incoming
describe Message, 'accessible attributes' do
  it 'should allow mass-assignment of the related model' do
    expect(Message.make).to allow_mass_assignment_of(:related => Issue.make!)
  end

  it 'should allow mass-assignment of the message ID header' do
    expect(Message.make).to allow_mass_assignment_of(:message_id_header => '<foo@example.com>')
  end

  it 'should allow mass-assignment of the to header' do
    expect(Message.make).to allow_mass_assignment_of(:to_header => 'recipient@example.org')
  end

  it 'should allow mass-assignment of the from header' do
    expect(Message.make).to allow_mass_assignment_of(:from_header => 'sender@example.net')
  end
  it 'should allow mass-assignment of the subject header' do
    expect(Message.make).to allow_mass_assignment_of(:subject_header => 'viagra')
  end

  it 'should allow mass-assignment of the in-reply-to header' do
    expect(Message.make).to allow_mass_assignment_of(:in_reply_to_header => '<msg@example.net>')
  end

  it 'should allow mass-assignment of the body' do
    expect(Message.make).to allow_mass_assignment_of(:body => 'bar')
  end

  it 'should allow mass-assignment of the incoming attribute' do
    expect(Message.make(:incoming => false)).to allow_mass_assignment_of(:incoming => true)
  end
end
