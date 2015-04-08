require 'base64'

shared_examples_for 'redirect_to_login' do
  it 'stores the original URI in the session' do
    do_request
    expect(session[:original_uri]).not_to be_blank
    expect(session[:original_uri]).to eq(response.request.fullpath)
  end

  it 'redirects to /login' do
    do_request
    expect(response).to redirect_to('/login')
  end
end

shared_examples_for 'require_admin' do
  it_has_behavior 'redirect_to_login'

  it 'shows a flash' do
    do_request
    expect(flash[:notice]).to match(/requires administrator privileges/)
  end
end

shared_examples_for 'require_admin (non-HTML)' do
  it 'returns status 403 (forbidden)' do
    do_request
    expect(response.status).to eq(403)
  end

  it 'renders "forbidden" test' do
    do_request
    expect(response.body).to match(/forbidden/i)
  end
end

shared_examples_for 'require_user' do
  it_has_behavior 'redirect_to_login'

  it 'shows a flash' do
    do_request
    expect(flash[:notice]).to match(/must be logged in to access/)
  end
end

# even though only included by the User model at this point, spec these
# using a shared example block just in case they ever get used elsewhere
# as well
shared_examples_for 'ActiveRecord::Authentication' do
  describe '#digest_version' do
    it 'is 1' do
      expect(subject.digest_version).to eq(1)
    end
  end

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

    it 'raises if the digest version is unsupported' do
      stub(subject).digest_version { 1000 }
      expect { subject.digest 'foo', 'bar' }
        .to raise_error(ArgumentError, /Unknown digest version/)
    end

    it 'returns different digests for varying salts' do
      digests = %w(salt1 salt2 salt3).map do |salt|
        subject.digest 'passphrase', salt
      end
      expect(digests.uniq.length).to eq(3)
    end

    it 'returns different digests for varying passphrases' do
      digests = %w(pass1 pass2 pass3).map do |pass|
        subject.digest pass, 'salt'
      end
      expect(digests.uniq.length).to eq(3)
    end

    it 'is idempotent (unchanging) for a given passphrase/salt pair' do
      pass, salt = 'pass', 'salt'
      expect(subject.digest(pass, salt)).to eq(subject.digest(pass, salt))
    end

    describe 'version 0' do
      before do
        stub(subject).digest_version { 0 }
      end

      it 'returns a SHA256 digest (64-character string in hex notation)' do
        expect(subject.digest('foo', 'bar')).to match(/\A[a-f0-9]{64}\z/)
      end

      it 'can be forced to use a later version' do
        digest = subject.digest('foo', 'bar', 1)
        expect(digest.length).to be > 128
      end
    end

    describe 'version 1' do
      before do
        stub(subject).digest_version { 1 }
      end

      it 'returns a base64-encoded string' do
        digest = subject.digest('foo', 'bar')
        expect(digest.length).to be > 128 # base-64 length may vary
        expect(Base64::encode64(Base64::decode64(digest))).to eq(digest)
      end
    end
  end
end
