require 'spec_helper'

describe Linking do
  describe 'Linking::LINK_REGEX' do
    it 'matches basic wiki links' do
      expect('[[foo bar]]').to match(Linking::LINK_REGEX)
    end

    it 'captures the subpattern inside the brackets' do
      '[[foo bar]]'.match(Linking::LINK_REGEX)
      expect($~[1]).to eq('foo bar')
    end

    it 'ignores leading and trailing whitespace' do
      expect('   [[foo bar]]   ').to match(Linking::LINK_REGEX)
    end

    it 'does not match when link contains an underscore' do
      expect('[[foo_bar]]').not_to match(Linking::LINK_REGEX)
    end

    it 'does not match when link contains a forward slash' do
      expect('[[foo/bar]]').not_to match(Linking::LINK_REGEX)
    end
  end

  describe 'Linking::EXTERNAL_LINK_REGEX' do
    it 'matches HTTP URLs' do
      expect('http://example.com/').to match(Linking::EXTERNAL_LINK_REGEX)
    end

    it 'matches HTTPS URLs' do
      expect('https://example.com/').to match(Linking::EXTERNAL_LINK_REGEX)
    end

    it 'ignores leading and trailing whitspace' do
      expect('   http://example.com/   ').to match(Linking::EXTERNAL_LINK_REGEX)
    end

    it 'captures the URL subpattern' do
      '   http://example.com/   '.match(Linking::EXTERNAL_LINK_REGEX)
      expect($~[1]).to eq('http://example.com/')
    end
  end

  describe 'Linking::RELATIVE_PATH_REGEX' do
    it 'matches relative paths' do
      expect('/foo/bar').to match(Linking::RELATIVE_PATH_REGEX)
    end

    it 'ignores leading and trailing whitespace' do
      expect('  /foo/bar  ').to match(Linking::RELATIVE_PATH_REGEX)
    end

    it 'captures the path subpattern' do
      '  /foo/bar  '.match(Linking::RELATIVE_PATH_REGEX)
      expect($~[1]).to eq('/foo/bar')
    end
  end

  describe '#url_for_link' do
    include Linking

    it 'is a private method' do
      expect(private_methods).to include(:url_for_link)
    end

    context 'with an internal (wiki) link' do
      let(:link) { '[[foo bar]]' }

      it 'returns the wiki article path' do
        expect(url_for_link(link)).to eq('/wiki/foo_bar')
      end
    end

    context 'with an external (HTTP) link' do
      let(:link) { 'http://example.com/' }

      it 'returns the URL' do
        expect(url_for_link(link)).to eq('http://example.com/')
      end
    end

    context 'with a relative path' do
      let(:link) { '/foo/bar' }

      it 'returns the path' do
        expect(url_for_link(link)).to eq('/foo/bar')
      end
    end

    context 'with nil' do
      let(:link) { nil }

      it 'returns nil' do
        expect(url_for_link(link)).to be_nil
      end
    end

    context 'with invalidly formatted link' do
      let(:link) { '--> click! <--' }

      it 'returns nil' do
        expect(url_for_link(link)).to be_nil
      end
    end
  end
end
