require 'spec_helper'

describe Reset do
  it 'should be valid' do
    Reset.make.should be_valid
  end

  describe 'attributes' do
    describe '#secret' do
      it 'defaults to nil' do
        Reset.new.secret.should be_nil
      end
    end

    describe '#cutoff' do
      it 'defaults to nil' do
        Reset.new.cutoff.should be_nil
      end
    end

    describe '#completed_at' do
      it 'defaults to nil' do
        Reset.new.completed_at.should be_nil
      end
    end

    describe '#created_at' do
      it 'defaults to nil' do
        Reset.new.created_at.should be_nil
      end
    end

    describe '#updated_at' do
      it 'defaults to nil' do
        Reset.new.updated_at.should be_nil
      end
    end

    describe '#email_id' do
      it 'defaults to nil' do
        Reset.new.email_id.should be_nil
      end
    end
  end
end

describe Reset, 'email address validation' do
  it 'should not require an email address for new records' do
    reset = Reset.make
    reset.email_address = nil
    reset.should_not fail_validation_for(:email_address)
  end

  it 'should require an email address for existing records' do
    reset = Reset.make!
    reset.email_address = nil
    reset.should fail_validation_for(:email_address)

    reset.email_address = reset.email.address
    reset.should_not fail_validation_for(:email_address)
  end

  it "should require the reset's email address to match the user's email address" do
    # set-up
    email = Email.make! :address => 'foo@example.com'
    reset = Reset.make! :email => email

    # success case
    reset.email_address = 'foo@example.com'
    reset.should_not fail_validation_for(:email_address)

    # failure case
    reset.email_address = 'bar@example.com'
    reset.should fail_validation_for(:email_address)
  end
end

describe Reset, 'accessible attributes' do
  it 'should allow mass-assignment to the email address' do
    Reset.make.should allow_mass_assignment_of(:email_address => 'foo@example.com')
  end
end

describe Reset, 'saving' do
  it 'should automatically generate a secret token if needed on saving' do
    reset = Reset.make :secret => nil
    reset.secret.should be_blank      # before
    reset.save
    reset.secret.should_not be_blank  # after
  end

  it 'should automatically insert a cutoff date if needed on saving' do
    reset = Reset.make :cutoff => nil
    reset.cutoff.should be_nil        # before
    reset.save
    reset.cutoff.should_not be_nil    # after
  end
end

describe Reset, 'secret token generation' do
  it 'should generate 40-character hash-based secret tokens' do
    Reset.secret.should match(/\A[a-f0-9]{40}\z/)
  end

  it 'should not generate the same secret token more than once' do
    tokens = []
    1_000.times { tokens << Reset.secret }
    tokens.size.should == 1_000
    tokens.uniq.size.should == 1_000
  end
end

describe Reset, 'parametrization' do
  it 'should use the secret token as its parameter' do
    reset = Reset.make! :secret => 'foo'
    reset.to_param.should == 'foo'
  end
end
