require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe User, 'generating a passphrase' do
  it 'should generate a string 8 characters in length' do
    1_000.times { User.passphrase.size.should == 8 }
  end

  it 'should not generate the same passphrase twice' do
    passphrases = Array.new(1_000) { User.passphrase }
    passphrases.uniq.size.should == 1_000
  end

  it 'should not generate passphrases with ambiguous characters (0, O, 1, l, I)' do
    1_000.times { User.passphrase.should_not match(/[0O1lI]/i) }
  end

  it 'should only generate passphrases with lowercase characters' do
    1_000.times do
      passphrase = User.passphrase
      passphrase.should == passphrase.downcase
    end
  end
end

describe User, 'setting a passphrase' do
  it 'should generate a new salt' do
    u = new_user
    old_salt = u.passphrase_salt
    u.passphrase = FR::random_string
    u.passphrase_salt.should_not == old_salt
  end

  it 'should generate a new hash' do
    u = new_user
    old_hash = u.passphrase_hash
    u.passphrase = FR::random_string
    u.passphrase_hash.should_not == old_hash
  end
end

describe User, 'authenticating' do
  before do
    @email      = "#{FR::random_string}@example.com"
    @passphrase = FR::random_string
    @user       = create_user :passphrase => @passphrase, :passphrase_confirmation => @passphrase
    @user.emails.create :address => @email
  end

  it 'should return nil if invalid email address' do
    User.authenticate(FR::random_string, @passphrase).should be_nil
  end

  it 'should return nil if invalid passphrase' do
    User.authenticate(@email, FR::random_string).should be_nil
  end

  it 'should return the user if valid email and passphrase' do
    User.authenticate(@email, @passphrase).should == @user
  end
end

describe User, 'accessible attributes' do
  it 'should allow mass-assignment to the display name' do
    new_user.should allow_mass_assignment_of(:display_name => FR::random_string)
  end

  it 'should allow mass-assignment to the passphrase (and confirmation)' do
    # have to test these two together otherwise validation fails
    passphrase = FR::random_string
    new_user.should allow_mass_assignment_of(:passphrase => passphrase, :passphrase_confirmation => passphrase)
  end

  it 'should allow mass-assignment to the old passphrase' do
    new_user.should allow_mass_assignment_of(:old_passphrase => FR::random_string)
  end
end

describe User, 'protected attributes' do
  it 'should deny mass-assignment to the passphrase hash' do
    new_user.should_not allow_mass_assignment_of(:passphrase_hash => FR::random_string)
  end

  it 'should deny mass-assignment to the passphrase salt' do
    new_user.should_not allow_mass_assignment_of(:passphrase_salt => FR::random_string)
  end

  it 'should deny mass-assignment to the superuser flag' do
    new_user.should_not allow_mass_assignment_of(:superuser => true)
  end

  it 'should deny mass-assignment to the verified flag' do
    new_user(:verified => false).should_not allow_mass_assignment_of(:verified => true)
  end

  it 'should deny mass-assignment to the suspended flag' do
    new_user.should_not allow_mass_assignment_of(:suspended => true)
  end

  it 'should deny mass-assignment to the session key' do
    new_user.should_not allow_mass_assignment_of(:session_key => FR::random_string)
  end

  it 'should deny mass-assignment to the session expiry' do
    new_user.should_not allow_mass_assignment_of(:session_expiry => Time.now)
  end

  it 'should deny mass-assignment to the deleted at field' do
    new_user.should_not allow_mass_assignment_of(:deleted_at => Time.now)
  end
end

describe User, 'validating the display name' do
  it 'should require it to be unique' do
    name = FR::random_string
    create_user(:display_name => name).should be_valid
    new_user(:display_name => name).should fail_validation_for(:display_name)
  end

  it 'should require it to be at least 3 characters long' do
    new_user(:display_name => FR::random_string(2)).should fail_validation_for(:display_name)
  end

  it 'should require it to begin with at least 2 letters' do
    new_user(:display_name => '12345678').should fail_validation_for(:display_name)
    new_user(:display_name => '__foobar').should fail_validation_for(:display_name)
  end

  it 'should disallow trailing spaces' do
    new_user(:display_name => 'foobar ').should fail_validation_for(:display_name)
  end

  it 'should disallow consecutive spaces' do
    new_user(:display_name => 'foo  bar').should fail_validation_for(:display_name)
  end

  it 'should allow letters, numbers and non-consecutive spaces' do
    new_user(:display_name => 'foo bar baz9').should be_valid
  end

  it 'should disallow all other characters' do
    new_user(:display_name => 'foo/bar').should fail_validation_for(:display_name)
    new_user(:display_name => 'foo$bar').should fail_validation_for(:display_name)
    new_user(:display_name => 'foo#bar').should fail_validation_for(:display_name)
  end
end

describe User, 'validating the passphrase' do
  it 'should require it to be present on new records' do
    # for some reason, FixtureReplacement 3.0 doesn't work here, so create
    # record manually (specifically, "new_user :passphrase => nil,
    # :passphrase_confirmation => nil" returns a valid model with a
    # passphrase set on it)
    # for full discussion see:
    #   http://github.com/smtlaissezfaire/fixturereplacement/issues#issue/10
    user = User.new :display_name => FR::random_string, :passphrase => nil, :passphrase_confirmation => nil
    user.should fail_validation_for(:passphrase)
  end

  it 'should not require it to be present on non-new records' do
    u = create_user
    u.passphrase = nil
    u.should be_valid
  end

  it 'should require it to be at least 8 characters long' do
    passphrase = FR::random_string(7)
    new_user(:passphrase => passphrase, :passphrase_confirmation => passphrase).should fail_validation_for(:passphrase)
  end

  it 'should require it to be confirmed' do
    user = new_user(:passphrase => FR::random_string, :passphrase_confirmation => FR::random_string)
    user.should fail_validation_for(:passphrase)
  end

  it 'should require the old password in order to set a new password' do
    passphrase = FR::random_string
    u = create_user(:passphrase => passphrase, :passphrase_confirmation => passphrase)
    u.should be_valid
    new_passphrase = FR::random_string
    u.update_attributes(:passphrase => new_passphrase, :passphrase_confirmation => new_passphrase)
    u.should fail_validation_for(:old_passphrase)
  end
end
