require 'spec_helper'

describe Confirmation do
  describe '#email_id' do
    it 'defaults to nil' do
      expect(Confirmation.new.email_id).to be_nil
    end
  end

  describe '#secret' do
    it 'defaults to nil' do
      expect(Confirmation.new.secret).to be_nil
    end
  end

  describe '#cutoff' do
    it 'defaults to nil' do
      expect(Confirmation.new.cutoff).to be_nil
    end
  end

  describe '#completed_at' do
    it 'defaults to nil' do
      expect(Confirmation.new.completed_at).to be_nil
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      expect(Confirmation.new.created_at).to be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      expect(Confirmation.new.updated_at).to be_nil
    end
  end
end
