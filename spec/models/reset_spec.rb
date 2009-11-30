require File.dirname(__FILE__) + '/../spec_helper'

describe Reset do
  it 'should be valid' do
    new_reset.should be_valid
  end
end

describe Reset, 'user validation' do
  it 'should require a user' do
    new_reset(:user => nil).should fail_validation_for(:user)
  end
end

describe Reset, 'email address validation' do
  it 'should not require an email address for new records' do
    new_reset(:email_address => nil).should_not fail_validation_for(:email_address)
  end

  it 'should require an email address for existing records' do
    create_reset(:email_address => nil).should fail_validation_for(:email_address)
  end

  it "should require the reset's email address to match the user's email address" do
    # set-up
    email = create_email(:address => 'foo@example.com')
    reset = email.user.resets.create
    reset.email = email
    reset.save

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
    new_reset.should allow_mass_assignment_of(:email_address => 'foo@example.com')
  end
end

describe Reset, 'protected attributes' do
  it 'should deny mass-assignment of the user' do
    new_reset.should_not allow_mass_assignment_of(:user => create_user)
  end

  it 'should deny mass-assignment of the secret token' do
    # rather than "new" use "create" to ensure that we have an autogenerated secret token
    create_reset.should_not allow_mass_assignment_of(:secret => 'foo')
  end

  it 'should deny mass-assignment of the cutoff' do
    # rather than "new" use "create" to ensure that we have an autogenerated cutoff date
    create_reset.should_not allow_mass_assignment_of(:cutoff => 100.days.from_now)
  end

  it 'should deny mass-assignment of the completion timestamp' do
    new_reset.should_not allow_mass_assignment_of(:user => 10.days.from_now)
  end
end

describe Reset, 'saving' do
  it 'should automatically generate a secret token if needed on saving' do
    reset = new_reset(:secret => nil)
    reset.secret.should be_blank      # before
    reset.save
    reset.secret.should_not be_blank  # after
  end

  it 'should automatically insert a cutoff date if needed on saving' do
    reset = new_reset(:cutoff => nil)
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
    reset = create_reset(:secret => 'foo')
    reset.to_param.should == 'foo'
  end
end
