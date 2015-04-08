require 'spec_helper'

describe Email do
  before do
    @email = Email.make!
  end

  it 'is valid' do
    expect(@email).to be_valid
  end

  describe 'parametrization' do
    it 'uses the email address as parameter' do
      email = Email.make! :address => 'nigel@example.com'
      expect(email.to_param).to eq('nigel@example.com')
    end

    context 'dirty record' do
      it 'uses the old address as param' do
        email = Email.make! :address => 'old@example.com'
        email.address = 'new@example.com'
        expect(email.to_param).to eq('old@example.com')
      end
    end
  end

  describe 'deleted method' do
    it 'is considered deleted if it has a deletion date' do
      @email.deleted_at = Time.now
      expect(@email.deleted).to eq(true)
    end

    it 'is considered not deleted if it does not have a deletion date' do
      @email.deleted_at = nil
      expect(@email.deleted).not_to eq(true)
    end
  end

  describe 'deleted? method' do
    it 'is considered deleted if it has a deletion date' do
      @email.deleted_at = Time.now
      expect(@email.deleted?).to eq(true)
    end

    it 'is considered not deleted if it does not have a deletion date' do
      @email.deleted_at = nil
      expect(@email.deleted?).not_to eq(true)
    end
  end

  describe 'deleting' do
    it 'deletes if passed a parameter of true' do
      @email.deleted = true
      expect(@email.deleted?).to eq(true)
    end

    it 'deletes if passed a parameter of "1"' do
      @email.deleted = '1'
      expect(@email.deleted?).to eq(true)
    end

    it 'deletes if passed any "truthy" parameter other than "0"' do
      @email.deleted = 'foo'
      expect(@email.deleted?).to eq(true)
    end

    it 'records the deletion date' do
      @email.deleted = true
      expect(@email.deleted_at).to be >= 1.second.ago
    end
  end

  describe 'undeleting' do
    it 'undeletes if passed a parameter of nil' do
      @email.deleted = nil
      expect(@email.deleted?).not_to eq(true)
    end

    it 'undeletes if passed a parameter of false' do
      @email.deleted = false
      expect(@email.deleted?).not_to eq(true)
    end

    it 'undeletes if passed a parameter of "0"' do
      @email.deleted = '0'
      expect(@email.deleted?).not_to eq(true)
    end
  end

  describe '#user_id' do
    it 'defaults to nil' do
      expect(Email.new.user_id).to be_nil
    end

    it 'must not be nil' do
      expect(Email.make(:user_id => nil)).to fail_validation_for(:user)
    end
  end

  describe '#address' do
    it 'defaults to nil' do
      expect(Email.new.address).to be_nil
    end

    it 'must not be nil' do
      expect(Email.make(:address => nil)).to fail_validation_for(:address)
    end

    it 'must not be blank' do
      expect(Email.make(:address => '')).to fail_validation_for(:address)
    end

    it 'must be of the form user@host.domain' do
      expect(Email.make(:address => 'hey@there')).to fail_validation_for(:address)
      expect(Email.make(:address => 'hey@example.com')).not_to fail_validation_for(:address)
    end
  end

  describe '#default' do
    it 'defaults to true' do
      expect(Email.new.default).to eq(true)
    end
  end

  describe '#verified' do
    it 'defaults to false' do
      expect(Email.new.verified).to eq(false)
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      expect(Email.new.created_at).to be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      expect(Email.new.updated_at).to be_nil
    end
  end

  describe '#deleted_at' do
    it 'defaults to nil' do
      expect(Email.new.deleted_at).to be_nil
    end
  end
end
