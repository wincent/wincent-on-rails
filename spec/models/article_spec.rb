require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Article do
  # we test a value larger than the default MySQL TEXT size (65535)
  it 'should support body content of over 128K' do
    # make sure the long body survives the round-trip from the db
    length = 128 * 1024
    long_body = 'x' * length
    article = Article.make! :body => long_body
    article.body.length.should == length
    article.reload
    article.body.length.should == length
  end
end

describe Article, 'creation' do
  before do
    @article = Article.create(:title => Sham.random, :body => Sham.random)
  end

  it 'should default to being public' do
    @article.public.should == true
  end

  it 'should default to accepting comments' do
    @article.accepts_comments.should == true
  end
end

describe Article, 'comments association' do
  it 'should respond to the comments message' do
    Article.make!.comments.should == []
  end
end

describe Article, 'acting as commentable' do
  before do
    @commentable = Article.make!
  end

  it_should_behave_like 'Commentable'
  it_should_behave_like 'Commentable not updating timestamps for comment changes'
end

describe Article, 'acting as taggable' do
  before do
    @object     = Article.make!
    @new_object = Article.make
  end

  it_should_behave_like 'ActiveRecord::Acts::Taggable'
end

# :title, :redirect, :body, :public, :accepts_comments, :pending_tags
describe Article, 'accessible attributes' do
  it 'should allow mass-assignment to the title' do
    Article.make.should allow_mass_assignment_of(:title => Sham.random)
  end

  it 'should allow mass-assignment to the redirect' do
    Article.make.should allow_mass_assignment_of(:body => "[[#{Sham.random}]]")
  end

  it 'should allow mass-assignment to the body' do
    Article.make.should allow_mass_assignment_of(:body => Sham.random)
  end

  it 'should allow mass-assignment to the public attribute' do
    Article.make(:public => false).should allow_mass_assignment_of(:public => true)
  end

  it 'should allow mass-assignment to the "accepts comments" attribute' do
    Article.make(:accepts_comments => false).should allow_mass_assignment_of(:accepts_comments => true)
  end

  it 'should allow mass-assignment to the "pending tags" attribute' do
    Article.make.should allow_mass_assignment_of(:pending_tags => 'foo bar baz')
  end
end

describe Article, 'validating the title' do
  it 'should require it to be present' do
     Article.make(:title => nil).should fail_validation_for(:title)
  end

  it 'should require it to be unique' do
    title = Sham.random
    Article.make!(:title => title).should be_valid
    Article.make(:title => title).should fail_validation_for(:title)
  end

  it 'should disallow underscores' do
    article = Article.make(:title => 'foo_bar').should fail_validation_for(:title)
  end
end

describe Article, 'validating the redirect' do
  it 'should require it to be present if the body is absent' do
    Article.make(:redirect => nil, :body => nil).should fail_validation_for(:redirect)
  end

  it 'should accept an HTTP URL' do
    Article.make(:redirect => 'http://example.com').should_not fail_validation_for(:redirect)
  end

  it 'should accept an HTTPS URL' do
    Article.make(:redirect => 'https://example.com').should_not fail_validation_for(:redirect)
  end

  it 'should accept relative URLs' do
    Article.make(:redirect => '/forums').should_not fail_validation_for(:redirect)
  end

  it 'should accept a [[wikitext]] title' do
    Article.make(:redirect => '[[foo bar]]').should_not fail_validation_for(:redirect)
  end

  it 'should ignore leading whitespace' do
    Article.make(:redirect => '   http://example.com').should_not fail_validation_for(:redirect)
    Article.make(:redirect => '   https://example.com').should_not fail_validation_for(:redirect)
    Article.make(:redirect => '   /forums').should_not fail_validation_for(:redirect)
    Article.make(:redirect => '   [[foo bar]]').should_not fail_validation_for(:redirect)
  end

  it 'should ignore trailing whitespace' do
    Article.make(:redirect => 'http://example.com   ').should_not fail_validation_for(:redirect)
    Article.make(:redirect => 'https://example.com   ').should_not fail_validation_for(:redirect)
    Article.make(:redirect => '/forums   ').should_not fail_validation_for(:redirect)
    Article.make(:redirect => '[[foo bar]]   ').should_not fail_validation_for(:redirect)
  end

  it 'should reject FTP URLs' do
    Article.make(:redirect => 'ftp://example.com/').should fail_validation_for(:redirect)
  end

  it 'should reject external wikitext links' do
    Article.make(:redirect => '[http://example.com/ link text]').should fail_validation_for(:redirect)
  end

  it 'should reject everything else' do
    Article.make(:redirect => 'hello world').should fail_validation_for(:redirect)
  end
end

describe Article, 'validating the body' do
  it 'should require it to be present if the redirect is absent' do
    Article.make(:redirect => nil, :body => nil).should fail_validation_for(:body)
  end

  it 'should complain if longer than 128k' do
    long_body = 'x' * (128 * 1024 + 100)
    Article.make(:body => long_body).should fail_validation_for(:body)
  end
end

describe Article, 'parametrization' do
  it 'should use the title as the param' do
    title = Sham.random
    Article.make(:title => title).to_param.should == title
  end

  it 'should convert spaces into underscores' do
    title = 'foo bar'
    Article.make(:title => title).to_param.should == title.gsub(' ', '_')
  end
end

describe Article, 'smart capitalization' do
  it 'should capitalize the first word only' do
    Article.smart_capitalize('foo bar').should == 'Foo bar'
  end

  it 'should leave other words untouched' do
    Article.smart_capitalize('foo IBM').should == 'Foo IBM'
  end

  it 'should not capitalize if the first word already contains capitals' do
    Article.smart_capitalize('WOPublic bar').should == 'WOPublic bar'
  end
end
