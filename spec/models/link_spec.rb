require 'spec_helper'

describe Link do
  describe 'URI validation' do
    it 'requires a URI' do
      link = Link.make :uri => nil
      expect(link).to fail_validation_for(:uri)
    end

    it 'requires URIs to be unique' do
      uri = 'http://example.com/'
      link = Link.make! :uri => uri
      expect(link).not_to fail_validation_for(:uri)
      link = Link.make :uri => uri
      expect(link).to fail_validation_for(:uri)
    end

    it 'accepts wiki links' do
      link = Link.make :uri => '[[foo bar]]'
      expect(link).not_to fail_validation_for(:uri)
    end

    it 'accepts HTTP URLs' do
      link = Link.make :uri => 'http://example.com/'
      expect(link).not_to fail_validation_for(:uri)
    end

    it 'accepts HTTPS URLs' do
      link = Link.make :uri => 'https://example.com/'
      expect(link).not_to fail_validation_for(:uri)
    end

    it 'accepts relative path URLs' do
      link = Link.make :uri => '/foo/bar'
      expect(link).not_to fail_validation_for(:uri)
    end

    it 'does not accept non-links' do
      link = Link.make :uri => 'not a link'
      expect(link).to fail_validation_for(:uri)
    end
  end

  describe 'permalink validation' do
    it 'should be valid without a permalink' do
      link = Link.make :permalink => nil
      expect(link).not_to fail_validation_for(:permalink)
    end

    it 'should require permalinks to be unique' do
      permalink = Sham.random
      link = Link.make! :permalink => permalink
      expect(link).not_to fail_validation_for(:permalink)
      link = Link.make :permalink => permalink
      expect(link).to fail_validation_for(:permalink)
    end

    it 'should accept nil permalinks without triggering uniqueness validation failures' do
      link = Link.make! :permalink => nil
      expect(link).not_to fail_validation_for(:permalink)
      link = Link.make :permalink => nil
      expect(link).not_to fail_validation_for(:permalink)
    end
  end

  describe 'accessible attributes' do
    it 'should allow mass-assignment to the uri' do
      expect(Link.make).to allow_mass_assignment_of(:uri => Sham.random)
    end

    it 'should allow mass-assignment to the permalink' do
      expect(Link.make).to allow_mass_assignment_of(:permalink => Sham.random)
    end
  end

  describe '#uri' do
    it 'defaults to nil' do
      expect(Link.new.uri).to be_nil
    end
  end

  describe '#permalink' do
    it 'defaults to nil' do
      expect(Link.new.permalink).to be_nil
    end
  end

  describe '#click_count' do
    it 'defaults to zero' do
      expect(Link.new.click_count).to be_zero
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      expect(Link.new.created_at).to be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      expect(Link.new.updated_at).to be_nil
    end
  end

  describe '#redirection_url' do
    context 'with a wiki link' do
      it 'redirects to the wiki' do
        link = Link.make! :uri => '[[foo bar]]'
        expect(link.redirection_url).to eq('/wiki/foo_bar')
      end
    end

    context 'with an HTTP URL' do
      it 'redirects to the URL' do
        link = Link.make! :uri => 'http://example.com'
        expect(link.redirection_url).to eq('http://example.com')
      end
    end

    context 'with an HTTPS URL' do
      it 'redirects to the URL' do
        link = Link.make! :uri => 'https://example.com'
        expect(link.redirection_url).to eq('https://example.com')
      end
    end

    context 'with a relative path' do
      it 'redirects to the path' do
        link = Link.make! :uri => '/issues/new'
        expect(link.redirection_url).to eq('/issues/new')
      end
    end
  end

  describe '#to_param' do
    it 'uses permalink as param if available' do
      link = Link.make!
      expect(link.to_param).to eq(link.permalink)
    end

    it 'uses id as param if permalink not available' do
      link = Link.make! :permalink => nil
      expect(link.to_param).to eq(link.id.to_s)
    end

    context 'new record' do
      it 'returns nil' do
        expect(Link.new.to_param).to eq('')
      end
    end

    context 'dirty record' do
      it 'returns the old (on database) permalink' do
        link = Link.make! :permalink => 'foo'
        link.permalink = 'bar'
        expect(link.to_param).to eq('foo')
      end
    end
  end

  describe 'click count' do
    it 'should default to 0' do
      expect(Link.make!.click_count).to eq(0)
    end
  end
end
