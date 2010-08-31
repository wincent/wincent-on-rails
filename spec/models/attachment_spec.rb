require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'pathname'

describe Attachment do
  describe '#digest' do
    it 'defaults to nil' do
      Attachment.new.digest.should be_nil
    end
  end

  describe '#path' do
    it 'defaults to nil' do
      Attachment.new.path.should be_nil
    end
  end

  describe '#mime_type' do
    it 'defaults to nil' do
      Attachment.new.mime_type.should be_nil
    end
  end

  describe '#user_id' do
    it 'defaults to nil' do
      Attachment.new.user_id.should be_nil
    end
  end

  describe '#original_filename' do
    it 'defaults to nil' do
      Attachment.new.original_filename.should be_nil
    end
  end

  describe '#filesize' do
    it 'defaults to nil' do
      Attachment.new.filesize.should be_nil
    end
  end

  describe '#attachable_id' do
    it 'defaults to nil' do
      Attachment.new.attachable_id.should be_nil
    end
  end

  describe '#attachable_type' do
    it 'defaults to nil' do
      Attachment.new.attachable_type.should be_nil
    end
  end

  describe '#awaiting_moderation' do
    it 'defaults to true' do
      Attachment.new.awaiting_moderation.should be_true
    end
  end

  describe '#public' do
    it 'defaults to true' do
      Attachment.new.public.should be_true
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      Attachment.new.created_at.should be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      Attachment.new.updated_at.should be_nil
    end
  end

  it 'should be valid' do
    pending
    create_attachment.should be_valid
  end

  it 'should have a 64-character hexadecimal digest' do
    pending
    create_attachment.digest.should =~ /\A[a-f0-9]{64}\z/
  end

  it 'should have a path based on a 2/64 split of the digest' do
    pending
    attachment = create_attachment
    digest = attachment.digest
    attachment.path.should == "#{digest[0..1]}/#{digest[2..63]}"
  end

  it 'should have a unique digest' do
    pending
    digests = []
    100.times { digests << create_attachment }
    digests.uniq.length.should == 100
  end
end

describe Attachment, 'validation' do
  it 'should require the digest to be unique' do
    pending
    older = create_attachment
    newer = create_attachment
    newer.digest = older.digest
    newer.should fail_validation_for(:digest)
  end
end

describe Attachment, 'regressions' do
  it 'should not update the path upon validation for existing records' do
    pending
    attachment = create_attachment
    path = attachment.path
    attachment.valid?
    attachment.path.should == path
  end

  it 'should not update the digest upon validation for existing records' do
    pending
    attachment = create_attachment
    digest = attachment.digest
    attachment.valid?
    attachment.digest.should == digest
  end
end

describe Attachment, 'assumptions' do
  describe 'Rails.root' do
    it 'should be a Pathname instance' do
      Rails.root.should be_kind_of(Pathname)
    end
  end
end
