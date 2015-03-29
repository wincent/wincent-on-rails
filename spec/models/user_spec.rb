require 'spec_helper'

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
    u = User.make
    old_salt = u.passphrase_salt
    u.passphrase = Sham.random
    u.passphrase_salt.should_not == old_salt
  end

  it 'should generate a new hash' do
    u = User.make
    old_hash = u.passphrase_hash
    u.passphrase = Sham.random
    u.passphrase_hash.should_not == old_hash
  end
end

describe User, 'authenticating' do
  before do
    @email      = "#{Sham.random}@example.com"
    @passphrase = Sham.random
    @user       = User.make!(
      passphrase: @passphrase,
      passphrase_confirmation: @passphrase
    )
    @user.emails.create address: @email
  end

  it 'should return nil if invalid email address' do
    User.authenticate(Sham.random, @passphrase).should be_nil
  end

  it 'should return nil if invalid passphrase' do
    User.authenticate(@email, Sham.random).should be_nil
  end

  it 'should return the user if valid email and passphrase' do
    User.authenticate(@email, @passphrase).should == @user
  end

  it 'updates a version 0 passhrase digest to version 1' do
    #  sanity check; confirm we start at version 1
    expect(@user.passphrase_salt.length).to be > 128

    # first we jump through some hoops to get it back into version 0 format
    salt = User.random_salt
    @user.passphrase_salt = salt
    @user.passphrase_hash = User.digest(@passphrase, salt, 0)
    @user.hash_version = 0
    @user.passphrase
    @user.save

    # confirm that it really is in version 0 format
    @user.reload
    expect(@user.passphrase_hash).to match(/\A[a-f0-9]{64}\z/)
    expect(@user.hash_version).to eq(0)

    # the actual update
    user = User.authenticate(@email, @passphrase)
    expect(user).to eq(@user)

    # confirm the version got bumped
    hash = user.passphrase_hash
    expect(hash.length).to be > 128
    expect(Base64::encode64(Base64::decode64(hash))).to eq(hash)
    expect(user.hash_version).to eq(1)
  end
end

describe User, 'accessible attributes' do
  it 'should allow mass-assignment to the display name' do
    User.make.should allow_mass_assignment_of(display_name: Sham.random)
  end

  it 'should allow mass-assignment to the passphrase (and confirmation)' do
    # have to test these two together otherwise validation fails
    passphrase = Sham.random
    User.make.should allow_mass_assignment_of(passphrase: passphrase, passphrase_confirmation: passphrase)
  end

  it 'should allow mass-assignment to the old passphrase' do
    User.make.should allow_mass_assignment_of(old_passphrase: Sham.random)
  end
end

describe User, 'validating the display name' do
  it 'must be present' do
    User.make(display_name: nil).should fail_validation_for(:display_name)
  end

  it 'should require it to be unique' do
    name = Sham.random
    User.make!(display_name: name).should be_valid
    User.make(display_name: name).should fail_validation_for(:display_name)
  end

  it 'should require it to be at least 3 characters long' do
    User.make(display_name: Sham.random[0..1]).should fail_validation_for(:display_name)
  end

  it 'should require it to begin with at least 2 letters' do
    User.make(display_name: '12345678').should fail_validation_for(:display_name)
    User.make(display_name: '__foobar').should fail_validation_for(:display_name)
  end

  it 'should disallow trailing spaces' do
    User.make(display_name: 'foobar ').should fail_validation_for(:display_name)
  end

  it 'should disallow consecutive spaces' do
    User.make(display_name: 'foo  bar').should fail_validation_for(:display_name)
  end

  it 'should allow letters, numbers and non-consecutive spaces' do
    User.make(display_name: 'foo bar baz9').should be_valid
  end

  it 'should disallow all other characters' do
    User.make(display_name: 'foo/bar').should fail_validation_for(:display_name)
    User.make(display_name: 'foo$bar').should fail_validation_for(:display_name)
    User.make(display_name: 'foo#bar').should fail_validation_for(:display_name)
  end
end

describe User, 'validating the passphrase' do
  it 'should require it to be present on new records' do
    user = User.make passphrase: nil, passphrase_confirmation: nil
    user.should fail_validation_for(:passphrase)
  end

  it 'should not require it to be present on non-new records' do
    u = User.make!
    u.passphrase = nil
    u.should be_valid
  end

  it 'should require it to be at least 8 characters long' do
    passphrase = Sham.random[0..6]
    User.make(passphrase: passphrase, passphrase_confirmation: passphrase).should fail_validation_for(:passphrase)
  end

  it 'should require it to be confirmed' do
    user = User.make(passphrase: Sham.random, passphrase_confirmation: Sham.random)
    user.should fail_validation_for(:passphrase_confirmation)
  end

  it 'should require the old password in order to set a new password' do
    passphrase = Sham.random
    u = User.make!(passphrase: passphrase, passphrase_confirmation: passphrase)
    u.should be_valid
    new_passphrase = Sham.random
    u.update_attributes(passphrase: new_passphrase, passphrase_confirmation: new_passphrase)
    u.should fail_validation_for(:old_passphrase)
  end
end

describe User do
  it_has_behavior 'ActiveRecord::Authentication' do
    subject { User }
  end

  describe '#display_name' do
    it 'defaults to nil' do
      User.new.display_name.should be_nil
    end
  end

  describe '#passphrase_hash' do
    it 'defaults to nil' do
      User.new.passphrase_hash.should be_nil
    end
  end

  describe '#passphrase_salt' do
    it 'defaults to nil' do
      User.new.passphrase_salt.should be_nil
    end
  end

  describe '#superuser' do
    it 'defaults to false' do
      User.new.superuser.should == false
    end
  end

  describe '#verified' do
    it 'defaults to false' do
      User.new.verified.should == false
    end
  end

  describe '#suspended' do
    it 'defaults to false' do
      User.new.suspended.should == false
    end
  end

  describe '#session_key' do
    it 'defaults to nil' do
      User.new.session_key.should be_nil
    end
  end

  describe '#session_expiry' do
    it 'defaults to nil' do
      User.new.session_expiry.should be_nil
    end
  end

  describe '#deleted_at' do
    it 'defaults to nil' do
      User.new.deleted_at.should be_nil
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      User.new.created_at.should be_nil
    end
  end

  describe '#comments_count' do
    it 'defaults to 0' do
      User.new.comments_count.should == 0
    end
  end

  describe '#topics_count' do
    it 'defaults to 0' do
      User.new.topics_count.should == 0
    end
  end

  describe '#to_param' do
    context 'new record' do
      it 'returns nil' do
        User.new.to_param.should be_nil
      end

      context 'with display name set' do
        it 'uses the display name as param' do
          user = User.new display_name: 'David Foo'
          user.to_param.should == 'david-foo'
        end
      end
    end

    context 'dirty record' do
      it 'uses the old (stored on database) display name as param' do
        user = User.make! display_name: 'John Smith'
        user.display_name = 'Jane Smith'
        user.to_param.should == 'john-smith'
      end
    end
  end

  describe 'emails association' do
    let(:user) { User.make! }

    it 'reports validation errors as "Email ..."' do
      user.emails.create address: 'faulty'
      user.should_not be_valid
      user.errors[:emails].should be_empty          # would be: "Emails is invalid"
      user.errors[:email].should == ['is invalid']  #  instead: "Email is invalid"
    end

    it 'reports validation errors within a transaction' do
      # basically double-checking that the pattern used in the users#create
      # action does the right thing
      user = User.make  # make and save in two steps
      user.save!        # otherwise, Factory Girl will auto-create an email
      expect do
        User.transaction do
          email = user.emails.create address: 'bad'
          email.save!
        end
      end.to raise_error(ActiveRecord::RecordInvalid)
      user.should_not be_valid
      user.errors[:emails].should be_empty          # would be: "Emails is invalid"
      user.errors[:email].should == ['is invalid']  #  instead: "Email is invalid"
    end
  end
end
