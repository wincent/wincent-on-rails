require 'spec_helper'

describe Article do
  # we test a value larger than the default MySQL TEXT size (65535)
  it 'should support body content of over 128K' do
    # make sure the long body survives the round-trip from the db
    long_body = ('x' * 127 + ' ') * 1024
    article = Article.make! body: long_body
    expect(article.body.length).to eq(long_body.length)
    article.reload
    expect(article.body.length).to eq(long_body.length)
  end

  it 'copes with really long words' do
    pending 'too lazy to fix for now'
    long_body = 'x' * 128 * 1024 # the Needle model will barf here
    article = Article.make! body: long_body
    expect(article.body.length).to eq(long_body.length)
    article.reload
    expect(article.body.length).to eq(long_body.length)
  end

  describe '#title' do
    it 'defaults to nil' do
      expect(Article.new.title).to be_nil
    end
  end

  describe '#redirect' do
    it 'defaults to nil' do
      expect(Article.new.redirect).to be_nil
    end
  end

  describe '#body' do
    it 'defaults to nil' do
      expect(Article.new.body).to be_nil
    end
  end

  describe '#public' do
    it 'defaults to true' do
      expect(Article.new.public).to eq(true)
    end
  end

  describe '#accepts_comments' do
    it 'defaults to true' do
      expect(Article.new.accepts_comments).to eq(true)
    end
  end

  describe '#comments_count' do
    it 'defaults to 0' do
      expect(Article.new.comments_count).to eq(0)
    end
  end

  describe '#created_at' do
    it 'defaults to nil' do
      expect(Article.new.created_at).to be_nil
    end
  end

  describe '#updated_at' do
    it 'defaults to nil' do
      expect(Article.new.updated_at).to be_nil
    end
  end

  describe '#last_commenter_id' do
    it 'defaults to nil' do
      expect(Article.new.last_commenter_id).to be_nil
    end
  end

  describe '#last_comment_id' do
    it 'defaults to nil' do
      expect(Article.new.last_comment_id).to be_nil
    end
  end

  describe '#last_commented_at' do
    it 'defaults to nil' do
      expect(Article.new.last_commented_at).to be_nil
    end
  end
end

describe Article, 'creation' do
  before do
    @article = Article.create(title: Sham.random, body: Sham.random)
  end

  it 'should default to being public' do
    expect(@article.public).to eq(true)
  end

  it 'should default to accepting comments' do
    expect(@article.accepts_comments).to eq(true)
  end
end

describe Article, 'comments association' do
  it 'should respond to the comments message' do
    expect(Article.make!.comments).to eq([])
  end
end

# :title, :redirect, :body, :public, :accepts_comments, :pending_tags
describe Article, 'accessible attributes' do
  it 'should allow mass-assignment to the title' do
    expect(Article.make).to allow_mass_assignment_of(title: Sham.random)
  end

  it 'should allow mass-assignment to the redirect' do
    expect(Article.make).to allow_mass_assignment_of(body: "[[#{Sham.random}]]")
  end

  it 'should allow mass-assignment to the body' do
    expect(Article.make).to allow_mass_assignment_of(body: Sham.random)
  end

  it 'should allow mass-assignment to the public attribute' do
    expect(Article.make(public: false)).to allow_mass_assignment_of(public: true)
  end

  it 'should allow mass-assignment to the "accepts comments" attribute' do
    expect(Article.make(accepts_comments: false)).to allow_mass_assignment_of(accepts_comments: true)
  end

  it 'should allow mass-assignment to the "pending tags" attribute' do
    expect(Article.make).to allow_mass_assignment_of(pending_tags: 'foo bar baz')
  end
end

describe Article, 'validating the title' do
  it 'should require it to be present' do
     expect(Article.make(title: nil)).to fail_validation_for(:title)
  end

  it 'should require it to be unique' do
    title = Sham.random
    expect(Article.make!(title: title)).to be_valid
    expect(Article.make(title: title)).to fail_validation_for(:title)
  end

  it 'should disallow underscores' do
    article = expect(Article.make(title: 'foo_bar')).to fail_validation_for(:title)
  end
end

describe Article, 'validating the redirect' do
  it 'should require it to be present if the body is absent' do
    expect(Article.make(redirect: nil, body: nil)).to fail_validation_for(:redirect)
  end

  it 'should accept an HTTP URL' do
    expect(Article.make(redirect: 'http://example.com')).not_to fail_validation_for(:redirect)
  end

  it 'should accept an HTTPS URL' do
    expect(Article.make(redirect: 'https://example.com')).not_to fail_validation_for(:redirect)
  end

  it 'should accept relative URLs' do
    expect(Article.make(redirect: '/forums')).not_to fail_validation_for(:redirect)
  end

  it 'should accept a [[wikitext]] title' do
    expect(Article.make(redirect: '[[foo bar]]')).not_to fail_validation_for(:redirect)
  end

  it 'should ignore leading whitespace' do
    expect(Article.make(redirect: '   http://example.com')).not_to fail_validation_for(:redirect)
    expect(Article.make(redirect: '   https://example.com')).not_to fail_validation_for(:redirect)
    expect(Article.make(redirect: '   /forums')).not_to fail_validation_for(:redirect)
    expect(Article.make(redirect: '   [[foo bar]]')).not_to fail_validation_for(:redirect)
  end

  it 'should ignore trailing whitespace' do
    expect(Article.make(redirect: 'http://example.com   ')).not_to fail_validation_for(:redirect)
    expect(Article.make(redirect: 'https://example.com   ')).not_to fail_validation_for(:redirect)
    expect(Article.make(redirect: '/forums   ')).not_to fail_validation_for(:redirect)
    expect(Article.make(redirect: '[[foo bar]]   ')).not_to fail_validation_for(:redirect)
  end

  it 'should reject FTP URLs' do
    expect(Article.make(redirect: 'ftp://example.com/')).to fail_validation_for(:redirect)
  end

  it 'should reject external wikitext links' do
    expect(Article.make(redirect: '[http://example.com/ link text]')).to fail_validation_for(:redirect)
  end

  it 'should reject everything else' do
    expect(Article.make(redirect: 'hello world')).to fail_validation_for(:redirect)
  end
end

describe Article, 'validating the body' do
  it 'should require it to be present if the redirect is absent' do
    expect(Article.make(redirect: nil, body: nil)).to fail_validation_for(:body)
  end

  it 'should complain if longer than 128k' do
    long_body = 'x' * (128 * 1024 + 100)
    expect(Article.make(body: long_body)).to fail_validation_for(:body)
  end
end

describe Article, 'smart capitalization' do
  it 'should capitalize the first word only' do
    expect(Article.smart_capitalize('foo bar')).to eq('Foo bar')
  end

  it 'should leave other words untouched' do
    expect(Article.smart_capitalize('foo IBM')).to eq('Foo IBM')
  end

  it 'should not capitalize if the first word already contains capitals' do
    expect(Article.smart_capitalize('WOPublic bar')).to eq('WOPublic bar')
  end
end

describe Article do
  let(:commentable) { Article.make! }
  it_has_behavior 'commentable'
  it_has_behavior 'commentable (not updating timestamps for comment changes)'

  it_has_behavior 'taggable' do
    let(:model) { Article.make! }
    let(:new_model) { Article.make }
  end

  describe '#find_with_param!' do
    before do
      @public = Article.make! title: 'foo'
      @private = Article.make! title: 'bar', public: false
    end

    context 'with no user param' do
      it 'finds public articles' do
        expect(Article.find_with_param!('foo')).to eq(@public)
      end

      it 'raises ActionController::ForbiddenError for private articles' do
        expect {
          Article.find_with_param! 'bar'
        }.to raise_error(ActionController::ForbiddenError)
      end
    end

    context 'with a normal user' do
      before do
        @user = User.make!
      end

      it 'finds public articles' do
        expect(Article.find_with_param!('foo', @user)).to eq(@public)
      end

      it 'raises ActionController::ForbiddenError for private articles' do
        expect {
          Article.find_with_param! 'bar', @user
        }.to raise_error(ActionController::ForbiddenError)
      end
    end

    context 'with an admin user' do
      before do
        @user = User.make! superuser: true
      end

      it 'finds public articles' do
        expect(Article.find_with_param!('foo', @user)).to eq(@public)
      end

      it 'finds private articles' do
        expect(Article.find_with_param!('bar', @user)).to eq(@private)
      end
    end
  end

  describe '#redirection_url' do
    context 'with no redirect' do
      it 'returns nil' do
        expect(Article.make!(redirect: nil).redirection_url).to be_nil
      end
    end

    context 'with blank redirect' do
      it 'returns nil' do
        expect(Article.make!(redirect: '').redirection_url).to be_nil
        expect(Article.make!(redirect: '  ').redirection_url).to be_nil
      end
    end

    context 'with internal wiki link' do
      it 'returns a relative path' do
        article = Article.make! redirect: '[[foo]]', body: ''
        expect(article.redirection_url).to eq('/wiki/foo')
      end

      context 'with excess whitespace' do
        it 'trims the excess' do
          article = Article.make! redirect: '  [[foo]]  ', body: ''
          expect(article.redirection_url).to eq('/wiki/foo')
        end
      end
    end

    context 'with HTTP URL' do
      it 'returns the full URL' do
        article = Article.make! redirect: 'http://example.com/', body: ''
        expect(article.redirection_url).to eq('http://example.com/')
      end

      context 'with excess whitespace' do
        it 'trims the excess' do
          article = Article.make! redirect: '  http://example.com/  ', body: ''
          expect(article.redirection_url).to eq('http://example.com/')
        end
      end
    end

    context 'with HTTPS URL' do
      it 'returns the full URL' do
        article = Article.make! redirect: 'https://example.com/', body: ''
        expect(article.redirection_url).to eq('https://example.com/')
      end

      context 'with excess whitespace' do
        it 'trims the excess' do
          article = Article.make! redirect: '  https://example.com/  ', body: ''
          expect(article.redirection_url).to eq('https://example.com/')
        end
      end
    end

    context 'with relative path' do
      it 'returns a relative path' do
        article = Article.make! redirect: '/issues/10', body: ''
        expect(article.redirection_url).to eq('/issues/10')
      end

      context 'with excess whitespace' do
        it 'trims the excess' do
          article = Article.make! redirect: '  /issues/10  ', body: ''
          expect(article.redirection_url).to eq('/issues/10')
        end
      end
    end

    context 'with invalid redirect' do
      # should never get here due to validations, but will test anyway
      it 'returns nil' do
        article = Article.make redirect: '---> fun!', body: ''
        article.save validate: false
        expect(article.redirection_url).to be_nil
      end
    end
  end

  describe '#to_param' do
    it 'uses the title as the param' do
      title = Sham.random
      expect(Article.make(title: title).to_param).to eq(title)
    end

    it 'converts spaces into underscores' do
      title = 'foo bar'
      expect(Article.make(title: title).to_param).to eq(title.gsub(' ', '_'))
    end

    context 'dirty record' do
      it 'uses the old title as param' do
        article = Article.make! title: 'foo'
        article.title = 'bar'
        expect(article.to_param).to eq('foo')
      end
    end
  end
end
