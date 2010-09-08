require 'spec_helper'

describe Snippet do

  # must use string here rather than literal constant or RSpec will try to
  # decorate the hash with metadata, causing a "can't modify frozen hash"
  # exception
  describe 'MARKUP_TYPES' do
    it 'does not allow modification of values' do
      expect do
        Snippet::MARKUP_TYPES['Wikitext'] = 'new'
      end.to raise_error(/frozen hash/)
    end

    it 'does not allow modification of keys' do
      expect do
        Snippet::MARKUP_TYPES.keys.first << 'more'
      end.to raise_error(/frozen string/)
    end
  end

  describe 'attributes' do
    describe '#description' do
      it 'defaults to nil' do
        Snippet.new.description.should be_nil
      end

      it 'is accessible' do
        snippet = Snippet.make :description => 'foo'
        snippet.should allow_mass_assignment_of :description => 'bar'
      end
    end

    describe '#markup_type' do
      it 'defaults to zero (wikitext)' do
        Snippet.new.markup_type.should == Snippet::MarkupType::WIKITEXT
      end

      it 'must be a valid markup type' do
        bad_markup_type = Snippet::MARKUP_TYPES.values.max * 2
        Snippet.make(:markup_type => bad_markup_type).
          should fail_validation_for(:markup_type)
      end

      it 'is accessible' do
        snippet = Snippet.make :markup_type => Snippet::MarkupType::WIKITEXT
        snippet.should allow_mass_assignment_of \
          :markup_type => Snippet::MarkupType::PLAINTEXT
      end
    end

    describe '#body' do
      it 'defaults to nil' do
        Snippet.new.body.should be_nil
      end

      it 'must not be nil' do
        Snippet.make(:body => nil).should fail_validation_for(:body)
      end

      it 'must not be blank' do
        Snippet.make(:body => '').should fail_validation_for(:body)
      end

      it 'is accessible' do
        snippet = Snippet.make :body => 'foo'
        snippet.should allow_mass_assignment_of :body => 'bar'
      end
    end

    describe '#created_at' do
      it 'defaults to nil' do
        Snippet.new.created_at.should be_nil
      end
    end

    describe '#updated_at' do
      it 'defaults to nil' do
        Snippet.new.updated_at.should be_nil
      end
    end

    describe '#public' do
      it 'defaults to true' do
        Snippet.new.public.should be_true
      end

      it 'is accessible' do
        snippet = Snippet.make :public => true
        snippet.should allow_mass_assignment_of :public => false
      end
    end

    describe '#comments_count' do
      it 'defaults to zero' do
        Snippet.new.comments_count.should be_zero
      end
    end

    describe '#accepts_comments' do
      it 'defaults to true' do
        Snippet.new.accepts_comments.should be_true
      end
    end
  end

  describe '#body_html' do
    context 'wikitext markup' do
      let(:snippet) do
        Snippet.make :markup_type => Snippet::MarkupType::WIKITEXT,
          :body => "''hey''"
      end

      it 'returns an HTML safe string' do
        snippet.body_html.html_safe?.should be_true
      end

      it 'transforms the body from wikitext into HTML' do
        snippet.body_html.should == "<p><em>hey</em></p>\n"
      end
    end

    context 'plaintext' do
      let(:snippet) do
        Snippet.make :markup_type => Snippet::MarkupType::PLAINTEXT,
          :body => 'fun & games'
      end

      it 'returns an HTML safe string' do
        snippet.body_html.html_safe?.should be_true
      end

      it 'escapes the body and wraps it in a "pre" block' do
        snippet.body_html.should == "<pre>fun &amp; games</pre>\n"
      end
    end

    context 'C syntax' do
      let(:snippet) do
        Snippet.make :markup_type => Snippet::MarkupType::C,
          :body => 'shits & giggles'
      end

      it 'returns an HTML safe string' do
        snippet.body_html.html_safe?.should be_true
      end

      it 'escapes the body and wraps it in a "pre.c-syntax" block' do
        snippet.body_html.
          should == %Q{<pre class="c-syntax">shits &amp; giggles</pre>\n}
      end
    end

    context 'diff syntax' do
      let(:snippet) do
        Snippet.make :markup_type => Snippet::MarkupType::DIFF,
          :body => 'foo & bar'
      end

      it 'returns an HTML safe string' do
        snippet.body_html.html_safe?.should be_true
      end

      it 'escapes the body and wraps it in a "pre.diff-syntax" block' do
        snippet.body_html.
          should == %Q{<pre class="diff-syntax">foo &amp; bar</pre>\n}
      end
    end

    context 'Objective-C syntax' do
      let(:snippet) do
        Snippet.make :markup_type => Snippet::MarkupType::OBJECTIVE_C,
          :body => '1 > 0'
      end

      it 'returns an HTML safe string' do
        snippet.body_html.html_safe?.should be_true
      end

      it 'escapes the body and wraps it in a "pre.objc-syntax" block' do
        snippet.body_html.
          should == %Q{<pre class="objc-syntax">1 &gt; 0</pre>\n}
      end
    end

    context 'Ruby syntax' do
      let(:snippet) do
        Snippet.make :markup_type => Snippet::MarkupType::RUBY,
          :body => '0 < 1'
      end

      it 'returns an HTML safe string' do
        snippet.body_html.html_safe?.should be_true
      end

      it 'escapes the body and wraps it in a "pre.ruby-syntax" block' do
        snippet.body_html.
          should == %Q{<pre class="ruby-syntax">0 &lt; 1</pre>\n}
      end
    end

    context 'shell syntax' do
      let(:snippet) do
        Snippet.make :markup_type => Snippet::MarkupType::SHELL,
          :body => '1 & 2'
      end

      it 'returns an HTML safe string' do
        snippet.body_html.html_safe?.should be_true
      end

      it 'escapes the body and wraps it in a "pre.shell-syntax" block' do
        snippet.body_html.
          should == %Q{<pre class="shell-syntax">1 &amp; 2</pre>\n}
      end
    end

    context 'unknown markup type' do
      let(:snippet) do
        bad_markup_type = Snippet::MARKUP_TYPES.values.max * 2
        Snippet.make :markup_type => bad_markup_type
      end

      it 'complains' do
        expect do
          snippet.body_html
        end.to raise_error(/unknown markup type/i)
      end
    end
  end
end
