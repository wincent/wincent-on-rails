require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'pathname'

describe Attachment do
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
