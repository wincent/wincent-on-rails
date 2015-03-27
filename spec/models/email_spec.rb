require 'spec_helper'

describe Email do
  before do
    @email = Email.make!
  end

  it 'is valid' do
    @email.should be_valid
  end

  describe 'parametrization' do
    it 'uses the email address as parameter' do
      email = Email.make! :address => 'nigel@example.com'
      email.to_param.should == 'nigel@example.com'
    end

    context 'dirty record' do
      it 'uses the old address as param' do
        email = Email.make! :address => 'old@example.com'
        email.address = 'new@example.com'
        email.to_param.should == 'old@example.com'
      end
    end
  end

  describe 'deleted method' do
    it 'is considered deleted if it has a deletion date' do
      @email.deleted_at = Time.now
      @email.deleted.should == true
    end

    it 'is considered not deleted if it does not have a deletion date' do
      @email.deleted_at = nil
      @email.deleted.should_not == true
    end
  end

  describe 'deleted? method' do
    it 'is considered deleted if it has a deletion date' do
      @email.deleted_at = Time.now
      @email.deleted?.should == true
    end

    it 'is considered not deleted if it does not have a deletion date' do
      @email.deleted_at = nil
      @email.deleted?.should_not == true
    end
  end

  describe 'deleting' do
    it 'deletes if passed a parameter of true' do
      @email.deleted = true
      @email.deleted?.should == true
    end

    it 'deletes if passed a parameter of "1"' do
      @email.deleted = '1'
      @email.deleted?.should == true
    end

    it 'deletes if passed any "truthy" parameter other than "0"' do
      @email.deleted = 'foo'
      @email.deleted?.should == true
    end

    it 'records the deletion date' do
      @email.deleted = true
      @email.deleted_at.should >= 1.second.ago
    end
  end

  describe 'undeleting' do
    it 'undeletes if passed a parameter of nil' do
      @email.deleted = nil
      @email.deleted?.should_not == true
    end

    it 'undeletes if passed a parameter of false' do
      @email.deleted = false
      @email.deleted?.should_not == true
    end

    it 'undeletes if passed a parameter of "0"' do
      @email.deleted = '0'
      @email.deleted?.should_not == true
    end
  end

  describe '#user_id' do
    it 'defaults to nil' do
      Email.new.user_id.should be_nil
    end

    it 'must not be nil' do
      Email.make(:user_id => nil).should fail_validation_for(:user)
    end
  end

  describe '#address' do
    it 'defaults to nil' do
      Email.new.address.should be_nil
    end

    it 'must not be nil' do
      Email.make(:address => nil).should fail_validation_for(:address)
    end

    it 'must not be blank' do
      Email.make(:address => '').should fail_validation_for(:address)
    end

    it 'must be of the form user@host.domain' do
      Email.make(:address => 'hey@there').should fail_validation_for(:address)
      Email.make(:address => 'hey@example.com').should_not fail_validation_for(:address)
    end
  end

  describe '#default' do
    it 'defaults to true' do
      Email.new.default.should == true
    end
  end

  describe '#verified' do
    it 'defaults to false' do
      Email.new.verified.should be_false
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      Email.new.created_at.should be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      Email.new.updated_at.should be_nil
    end
  end

  describe '#deleted_at' do
    it 'defaults to nil' do
      Email.new.deleted_at.should be_nil
    end
  end
end
