require File.dirname(__FILE__) + '/../spec_helper'

describe User, 'creation' do
  it 'should promote (only) the first-created user to superuser' do
    User.delete(:all)
    create_user.should be_superuser
    create_user.should_not be_superuser
  end
end

describe User, 'generating a passphrase' do
  it 'should generate a string 8 characters in length' do
    1_000.times { User.passphrase.size.should == 8 }
  end

  it 'should not generate the same passphrase twice' do
    passphrases = []
    1_000.times { passphrases << User.passphrase }
    passphrases.size.should == passphrases.uniq.size
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
    u.passphrase = String.random
    u.passphrase_salt.should_not == old_salt
  end

  it 'should generate a new hash' do
    u = new_user
    old_hash = u.passphrase_hash
    u.passphrase = String.random
    u.passphrase_hash.should_not == old_hash
  end
end

describe User, 'authenticating' do
  it 'should return nil if invalid login name' do
    passphrase = String.random
    create_user(:passphrase => passphrase, :passphrase_confirmation => passphrase)
    User.authenticate(String.random, passphrase).should be_nil
  end

  it 'should return nil if invalid passphrase' do
    login = String.random
    create_user(:login_name => login)
    User.authenticate(login, String.random)
  end

  it 'should return the user if valid login and passphrase' do
    login, passphrase = String.random, String.random
    u = create_user(:login_name => login, :passphrase => passphrase, :passphrase_confirmation => passphrase)
    User.authenticate(login, passphrase).should == u
  end
end

describe User, 'accessible attributes' do
  it 'should allow mass-assignment to the login name' do
    lambda { new_user.update_attributes(:login_name => String.random) }.should_not raise_error
  end

  it 'should allow mass-assignment to the display name' do
    lambda { new_user.update_attributes(:display_name => String.random) }.should_not raise_error
  end

  it 'should allow mass-assignment to the passphrase' do
    lambda { new_user.update_attributes(:passphrase => String.random) }.should_not raise_error
  end

  it 'should allow mass-assignment to the passphrase confirmation' do
    lambda { new_user.update_attributes(:passphrase_confirmation => String.random) }.should_not raise_error
  end

  it 'should allow mass-assignment to the old passphrase' do
    lambda { new_user.update_attributes(:old_passphrase => String.random) }.should_not raise_error
  end

  it 'should allow mass-assignment to the locale' do
    lambda { new_user.update_attributes(:locale => new_locale) }.should_not raise_error
  end
end

describe User, 'protected attributes' do
  it 'should deny mass-assignment to the passphrase hash' do
    lambda { new_user.update_attributes(:passphrase_hash => String.random) }.should raise_error
  end

  it 'should deny mass-assignment to the passphrase salt' do
    lambda { new_user.update_attributes(:passphrase_salt => String.random) }.should raise_error
  end

  it 'should deny mass-assignment to the superuser flag' do
    lambda { new_user.update_attributes(:superuser => true) }.should raise_error
  end

  it 'should deny mass-assignment to the verified flag' do
    lambda { new_user.update_attributes(:verified => true) }.should raise_error
  end

  it 'should deny mass-assignment to the suspended flag' do
    lambda { new_user.update_attributes(:suspended => true) }.should raise_error
  end

  it 'should deny mass-assignment to the session key' do
    lambda { new_user.update_attributes(:session_key => String.random) }.should raise_error
  end

  it 'should deny mass-assignment to the session expiry' do
    lambda { new_user.update_attributes(:session_expiry => Time.now) }.should raise_error
  end

  it 'should deny mass-assignment to the deleted at field' do
    lambda { new_user.update_attributes(:deleted_at => Time.now) }.should raise_error
  end
end

describe User, 'validating the login name' do
  it 'should require it to be present' do
     new_user(:login_name => nil).should fail_validation_for(:login_name)
  end

  it 'should require it to be unique' do
    name = String.random
    create_user(:login_name => name).should be_valid
    new_user(:login_name => name).should fail_validation_for(:login_name)
  end

  it 'should require it to be at least 3 characters long' do
    new_user(:login_name => String.random(2)).should fail_validation_for(:login_name)
  end

  it 'should require it to begin with at least 2 letters' do
    new_user(:login_name => '12345678').should fail_validation_for(:login_name)
    new_user(:login_name => '__foobar').should fail_validation_for(:login_name)
  end

  it 'should disallow trailing spaces' do
    new_user(:login_name => 'foobar ').should fail_validation_for(:login_name)
  end

  it 'should disallow consecutive spaces' do
    new_user(:login_name => 'foo  bar').should fail_validation_for(:login_name)
  end

  it 'should allow letters, numbers, underscores, and non-consecutive spaces' do
    new_user(:login_name => 'foo bar_baz9').should be_valid
  end

  it 'should disallow all other characters' do
    new_user(:login_name => 'foo/bar').should fail_validation_for(:login_name)
    new_user(:login_name => 'foo$bar').should  fail_validation_for(:login_name)
    new_user(:login_name => 'foo#bar').should  fail_validation_for(:login_name)
  end
end

describe User, 'validating the display name' do
  it 'should use the login name as a display name if display name not present' do
     u = new_user(:display_name => nil)
     u.should be_valid
     u.display_name.should == u.login_name
  end

  it 'should require it to be unique' do
    name = String.random
    create_user(:display_name => name).should be_valid
    new_user(:display_name => name).should fail_validation_for(:display_name)
  end

  it 'should require it to be at least 3 characters long' do
    new_user(:display_name => String.random(2)).should fail_validation_for(:display_name)
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

  it 'should allow letters, numbers, underscores, and non-consecutive spaces' do
    new_user(:display_name => 'foo bar_baz9').should be_valid
  end

  it 'should disallow all other characters' do
    new_user(:display_name => 'foo/bar').should fail_validation_for(:display_name)
    new_user(:display_name => 'foo$bar').should  fail_validation_for(:display_name)
    new_user(:display_name => 'foo#bar').should  fail_validation_for(:display_name)
  end
end

describe User, 'validating the passphrase' do
  it 'should require it to be present on new records' do
    new_user(:passphrase => nil, :passphrase_confirmation => nil).should fail_validation_for(:passphrase)
  end

  it 'should not require it to be present on non-new records' do
    u = create_user
    u.passphrase = nil
    u.should be_valid
  end

  it 'should require it to be at least 8 characters long' do
    passphrase = String.random(7)
    new_user(:passphrase => passphrase, :passphrase_confirmation => passphrase).should fail_validation_for(:passphrase)
  end

  it 'should require it to be confirmed' do
    new_user(:passphrase => String.random, :passphrase_confirmation => String.random).should fail_validation_for(:passphrase)
  end

  it 'should require the old password in order to set a new password' do
    passphrase = String.random
    u = create_user(:passphrase => passphrase, :passphrase_confirmation => passphrase)
    u.should be_valid
    new_passphrase = String.random
    u.update_attributes(:passphrase => new_passphrase, :passphrase_confirmation => new_passphrase)
    u.should fail_validation_for(:old_passphrase)
  end
end
