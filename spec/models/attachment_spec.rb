require 'spec_helper'
require 'pathname'

describe Attachment do
  describe '#digest' do
    it 'defaults to nil' do
      expect(Attachment.new.digest).to be_nil
    end
  end

  describe '#path' do
    it 'defaults to nil' do
      expect(Attachment.new.path).to be_nil
    end
  end

  describe '#mime_type' do
    it 'defaults to nil' do
      expect(Attachment.new.mime_type).to be_nil
    end
  end

  describe '#user_id' do
    it 'defaults to nil' do
      expect(Attachment.new.user_id).to be_nil
    end
  end

  describe '#original_filename' do
    it 'defaults to nil' do
      expect(Attachment.new.original_filename).to be_nil
    end
  end

  describe '#filesize' do
    it 'defaults to nil' do
      expect(Attachment.new.filesize).to be_nil
    end
  end

  describe '#attachable_id' do
    it 'defaults to nil' do
      expect(Attachment.new.attachable_id).to be_nil
    end
  end

  describe '#attachable_type' do
    it 'defaults to nil' do
      expect(Attachment.new.attachable_type).to be_nil
    end
  end

  describe '#awaiting_moderation' do
    it 'defaults to true' do
      expect(Attachment.new.awaiting_moderation).to eq(true)
    end
  end

  describe '#public' do
    it 'defaults to true' do
      expect(Attachment.new.public).to eq(true)
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      expect(Attachment.new.created_at).to be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      expect(Attachment.new.updated_at).to be_nil
    end
  end

  it 'should be valid' do
    pending
    expect(create_attachment).to be_valid
  end

  it 'should have a 64-character hexadecimal digest' do
    pending
    expect(create_attachment.digest).to match(/\A[a-f0-9]{64}\z/)
  end

  it 'should have a path based on a 2/64 split of the digest' do
    pending
    attachment = create_attachment
    digest = attachment.digest
    expect(attachment.path).to eq("#{digest[0..1]}/#{digest[2..63]}")
  end

  it 'should have a unique digest' do
    pending
    digests = []
    100.times { digests << create_attachment }
    expect(digests.uniq.length).to eq(100)
  end
end

describe Attachment, 'validation' do
  it 'should require the digest to be unique' do
    pending
    older = create_attachment
    newer = create_attachment
    newer.digest = older.digest
    expect(newer).to fail_validation_for(:digest)
  end
end

describe Attachment, 'regressions' do
  it 'should not update the path upon validation for existing records' do
    pending
    attachment = create_attachment
    path = attachment.path
    attachment.valid?
    expect(attachment.path).to eq(path)
  end

  it 'should not update the digest upon validation for existing records' do
    pending
    attachment = create_attachment
    digest = attachment.digest
    attachment.valid?
    expect(attachment.digest).to eq(digest)
  end
end

describe Attachment, 'assumptions' do
  describe 'Rails.root' do
    it 'should be a Pathname instance' do
      expect(Rails.root).to be_kind_of(Pathname)
    end
  end
end
