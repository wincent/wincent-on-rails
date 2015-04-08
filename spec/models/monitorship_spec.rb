require 'spec_helper'

describe Monitorship do
  describe '#user_id' do
    it 'defaults to nil' do
      expect(Monitorship.new.user_id).to be_nil
    end
  end

  describe '#monitorable_id' do
    it 'defaults to nil' do
      expect(Monitorship.new.monitorable_id).to be_nil
    end
  end

  describe '#monitorable_type' do
    it 'defaults to nil' do
      expect(Monitorship.new.monitorable_type).to be_nil
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      expect(Monitorship.new.created_at).to be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      expect(Monitorship.new.updated_at).to be_nil
    end
  end
end

describe Monitorship, 'validation' do
  it 'should require the user association to be set' do
    expect(Monitorship.new).to fail_validation_for(:user)
  end

  it 'should require the monitorable association to be set' do
    expect(Monitorship.new).to fail_validation_for(:monitorable)
  end
end
