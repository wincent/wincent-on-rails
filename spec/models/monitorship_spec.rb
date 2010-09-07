require 'spec_helper'

describe Monitorship do
  describe '#user_id' do
    it 'defaults to nil' do
      Monitorship.new.user_id.should be_nil
    end
  end

  describe '#monitorable_id' do
    it 'defaults to nil' do
      Monitorship.new.monitorable_id.should be_nil
    end
  end

  describe '#monitorable_type' do
    it 'defaults to nil' do
      Monitorship.new.monitorable_type.should be_nil
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      Monitorship.new.created_at.should be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      Monitorship.new.updated_at.should be_nil
    end
  end
end

describe Monitorship, 'validation' do
  it 'should require the user association to be set' do
    Monitorship.new.should fail_validation_for(:user)
  end

  it 'should require the monitorable association to be set' do
    Monitorship.new.should fail_validation_for(:monitorable)
  end
end
