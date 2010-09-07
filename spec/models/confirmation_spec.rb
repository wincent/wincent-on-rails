require 'spec_helper'

describe Confirmation do
  describe '#email_id' do
    it 'defaults to nil' do
      Confirmation.new.email_id.should be_nil
    end
  end

  describe '#secret' do
    it 'defaults to nil' do
      Confirmation.new.secret.should be_nil
    end
  end

  describe '#cutoff' do
    it 'defaults to nil' do
      Confirmation.new.cutoff.should be_nil
    end
  end

  describe '#completed_at' do
    it 'defaults to nil' do
      Confirmation.new.completed_at.should be_nil
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      Confirmation.new.created_at.should be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      Confirmation.new.updated_at.should be_nil
    end
  end
end
