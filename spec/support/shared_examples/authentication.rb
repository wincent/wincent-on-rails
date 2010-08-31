shared_examples_for 'redirect_to_login' do
  it 'stores the original URI in the session' do
    do_request
    session[:original_uri].should_not be_blank
    session[:original_uri].should == response.request.fullpath
  end

  it 'redirects to /login' do
    do_request
    response.should redirect_to('/login')
  end
end

shared_examples_for 'require_admin' do
  it_has_behavior 'redirect_to_login'

  it 'shows a flash' do
    do_request
    cookie_flash[:notice].should =~ /requires administrator privileges/
  end
end

shared_examples_for 'require_admin (non-HTML)' do
  it 'returns status 403 (forbidden)' do
    do_request
    response.status.should == 403
  end

  it 'renders "forbidden" test' do
    do_request
    response.body.should match(/forbidden/i)
  end
end

shared_examples_for 'require_user' do
  it_has_behavior 'redirect_to_login'

  it 'shows a flash' do
    do_request
    cookie_flash[:notice].should =~ /must be logged in to access/
  end
end

# even though only included by the User model at this point, spec these
# using a shared example block just in case they ever get used elsewhere
# as well
shared_examples_for 'ActiveRecord::Authentication' do
  describe '#digest' do
    it 'raises if passphrase is nil' do
      expect do
        subject.digest nil, 'salt'
      end.to raise_error(ArgumentError, /nil passphrase/)
    end

    it 'raises if salt is nil' do
      expect do
        subject.digest 'passphrase', nil
      end.to raise_error(ArgumentError, /nil salt/)
    end

    it 'returns a SHA256 digest (64-character string in hex notation)' do
      subject.digest('foo', 'bar').should =~ /\A[a-f0-9]{64}\z/
    end

    it 'returns different digests for varying salts' do
      digests = %w(salt1 salt2 salt3).map do |salt|
        subject.digest 'passphrase', salt
      end
      digests.uniq.length.should == 3
    end

    it 'returns different digests for varying passphrases' do
      digests = %w(pass1, pass2, pass3).map do |pass|
        subject.digest pass, 'salt'
      end
      digests.uniq.length.should == 3
    end

    it 'is idempotent (unchanging) for a given passphrase/salt pair' do
      pass, salt = 'pass', 'salt'
      subject.digest(pass, salt).should == subject.digest(pass, salt)
    end
  end
end
