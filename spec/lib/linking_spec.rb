require 'spec_helper'

describe Linking do
  describe Linking::LINK_REGEX do
    it 'matches basic wiki links' do
      '[[foo bar]]'.should match(Linking::LINK_REGEX)
    end

    it 'captures the subpattern inside the brackets' do
      '[[foo bar]]'.match(Linking::LINK_REGEX)
      $~[1].should == 'foo bar'
    end

    it 'ignores leading and trailing whitespace' do
      '   [[foo bar]]   '.should match(Linking::LINK_REGEX)
    end

    it 'does not match when link contains an underscore' do
      '[[foo_bar]]'.should_not match(Linking::LINK_REGEX)
    end

    it 'does not match when link contains a forward slash' do
      '[[foo/bar]]'.should_not match(Linking::LINK_REGEX)
    end
  end

  describe Linking::EXTERNAL_LINK_REGEX do
    it 'matches HTTP URLs' do
      'http://example.com/'.should match(Linking::EXTERNAL_LINK_REGEX)
    end

    it 'matches HTTPS URLs' do
      'https://example.com/'.should match(Linking::EXTERNAL_LINK_REGEX)
    end

    it 'ignores leading and trailing whitspace' do
      '   http://example.com/   '.should match(Linking::EXTERNAL_LINK_REGEX)
    end

    it 'captures the URL subpattern' do
      '   http://example.com/   '.match(Linking::EXTERNAL_LINK_REGEX)
      $~[1].should == 'http://example.com/'
    end
  end

  describe Linking::RELATIVE_PATH_REGEX do
    it 'matches relative paths' do
      '/foo/bar'.should match(Linking::RELATIVE_PATH_REGEX)
    end

    it 'ignores leading and trailing whitespace' do
      '  /foo/bar  '.should match(Linking::RELATIVE_PATH_REGEX)
    end

    it 'captures the path subpattern' do
      '  /foo/bar  '.match(Linking::RELATIVE_PATH_REGEX)
      $~[1].should == '/foo/bar'
    end
  end

  describe '#url_for_link' do
    include Linking

    it 'is a private method' do
      private_methods.should include('url_for_link')
    end

    context 'with an internal (wiki) link' do
      let(:link) { '[[foo bar]]' }

      it 'returns the wiki article path' do
        url_for_link(link).should == '/wiki/foo_bar'
      end
    end

    context 'with an external (HTTP) link' do
      let(:link) { 'http://example.com/' }

      it 'returns the URL' do
        url_for_link(link).should == 'http://example.com/'
      end
    end

    context 'with a relative path' do
      let(:link) { '/foo/bar' }

      it 'returns the path' do
        url_for_link(link).should == '/foo/bar'
      end
    end

    context 'with nil' do
      let(:link) { nil }

      it 'returns nil' do
        url_for_link(link).should be_nil
      end
    end

    context 'with invalidly formatted link' do
      let(:link) { '--> click! <--' }

      it 'returns nil' do
        url_for_link(link).should be_nil
      end
    end
  end
end
