require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Email do
  before do
    @email = Email.make!
  end

  it 'is valid' do
    @email.should be_valid
  end

  describe 'parametrization' do
    it 'uses the email address as parameter' do
      @email.address = 'nigel@example.com'
      @email.to_param.should == 'nigel@example.com'
    end
  end

  describe 'deleted method' do
    it 'is considered deleted if it has a deletion date' do
      @email.deleted_at = Time.now
      @email.deleted.should be_true
    end

    it 'is considered not deleted if it does not have a deletion date' do
      @email.deleted_at = nil
      @email.deleted.should_not be_true
    end
  end

  describe 'deleted? method' do
    it 'is considered deleted if it has a deletion date' do
      @email.deleted_at = Time.now
      @email.deleted?.should be_true
    end

    it 'is considered not deleted if it does not have a deletion date' do
      @email.deleted_at = nil
      @email.deleted?.should_not be_true
    end
  end

  describe 'deleting' do
    it 'deletes if passed a parameter of true' do
      @email.deleted = true
      @email.deleted?.should be_true
    end

    it 'deletes if passed a parameter of "1"' do
      @email.deleted = '1'
      @email.deleted?.should be_true
    end

    it 'deletes if passed any "truthy" parameter other than "0"' do
      @email.deleted = 'foo'
      @email.deleted?.should be_true
    end

    it 'records the deletion date' do
      @email.deleted = true
      @email.deleted_at.should >= 1.second.ago
    end
  end

  describe 'undeleting' do
    it 'undeletes if passed a parameter of nil' do
      @email.deleted = nil
      @email.deleted?.should_not be_true
    end

    it 'undeletes if passed a parameter of false' do
      @email.deleted = false
      @email.deleted?.should_not be_true
    end

    it 'undeletes if passed a parameter of "0"' do
      @email.deleted = '0'
      @email.deleted?.should_not be_true
    end
  end
end
