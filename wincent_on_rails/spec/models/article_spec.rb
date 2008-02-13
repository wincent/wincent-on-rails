require File.dirname(__FILE__) + '/../spec_helper'

describe Article, 'creation' do
  before do
    @article = Article.create(:title => String.random, :body => String.random)
  end

  it 'should default to being public' do
    @article.public.should == true
  end

  it 'should default to not accepting comments' do
    @article.accepts_comments.should == false
  end
end

describe Article, 'comments association' do
  it 'should respond to the comments message' do
    create_article.comments.should == []
  end
end

describe Article, 'virtual attributes' do
  it 'should have a pending_tags virtual attribute' do
    article = new_article
    tags    = 'foo bar baz'
    article.pending_tags = tags
    article.pending_tags.should == tags
  end
end

describe Article, 'acting as taggable' do
  before do
    @article = create_article
  end

  it 'should respond to the tag message' do
    @article.tag 'foo'
    @article.tag_names.should == ['foo']
  end

  it 'should respond to the untag message' do
    @article.tag 'foo'
    @article.untag 'foo'
    @article.tag_names.should == []
  end

  it 'should respond to the tag_names message' do
    @article.tag_names.should == []
  end

  it 'should allow tagging at creation time' do
    # we explicitly test this because this is a "has many through" association and so isn't automatic
    article = create_article(:pending_tags => 'foo bar baz')
    article.tag_names.should == ['foo', 'bar', 'baz']
  end
end

# :title, :redirect, :body, :public, :accepts_comments, :pending_tags
describe Article, 'accessible attributes' do
  it 'should allow mass-assignment to the title' do
    new_article.should allow_mass_assignment_of(:title => String.random)
  end

  it 'should allow mass-assignment to the redirect' do
    new_article.should allow_mass_assignment_of(:body => "[[#{String.random}]]")
  end

  it 'should allow mass-assignment to the body' do
    new_article.should allow_mass_assignment_of(:body => String.random)
  end

  it 'should allow mass-assignment to the public attribute' do
    new_article(:public => false).should allow_mass_assignment_of(:public => true)
  end

  it 'should allow mass-assignment to the "accepts comments" attribute' do
    new_article(:accepts_comments => false).should allow_mass_assignment_of(:accepts_comments => true)
  end

  it 'should allow mass-assignment to the "pending tags" attribute' do
    new_article.should allow_mass_assignment_of(:pending_tags => 'foo bar baz')
  end
end

describe Article, 'validating the title' do
  it 'should require it to be present' do
     new_article(:title => nil).should fail_validation_for(:title)
  end

  it 'should require it to be unique' do
    title = String.random
    create_article(:title => title).should be_valid
    new_article(:title => title).should fail_validation_for(:title)
  end
end

describe Article, 'validating the redirect' do
  it 'should require it to be present if the body is absent' do
    new_article(:redirect => nil, :body => nil).should fail_validation_for(:redirect)
  end

  it 'should accept an HTTP URL' do
    new_article(:redirect => 'http://example.com').should_not fail_validation_for(:redirect)
  end

  it 'should accept an HTTPS URL' do
    new_article(:redirect => 'https://example.com').should_not fail_validation_for(:redirect)
  end

  it 'should accept a [[wikitext]] title' do
    new_article(:redirect => '[[foo bar]]').should_not fail_validation_for(:redirect)
  end

  it 'should ignore leading whitespace' do
    new_article(:redirect => '   http://example.com').should_not fail_validation_for(:redirect)
    new_article(:redirect => '   https://example.com').should_not fail_validation_for(:redirect)
    new_article(:redirect => '   [[foo bar]]').should_not fail_validation_for(:redirect)
  end

  it 'should ignore trailing whitespace' do
    new_article(:redirect => 'http://example.com   ').should_not fail_validation_for(:redirect)
    new_article(:redirect => 'https://example.com   ').should_not fail_validation_for(:redirect)
    new_article(:redirect => '[[foo bar]]   ').should_not fail_validation_for(:redirect)
  end

  it 'should reject FTP URLs' do
    new_article(:redirect => 'ftp://example.com/').should fail_validation_for(:redirect)
  end

  it 'should reject external wikitext links' do
    new_article(:redirect => '[http://example.com/ link text]').should fail_validation_for(:redirect)
  end

  it 'should reject everything else' do
    new_article(:redirect => 'hello world').should fail_validation_for(:redirect)
  end
end

describe Article, 'validating the body' do
  it 'should require it to be present if the redirect is absent' do
    new_article(:redirect => nil, :body => nil).should fail_validation_for(:body)
  end
end

describe Article, 'parametrization' do
  it 'should use the title as the param' do
    title = String.random
    new_article(:title => title).to_param.should == title
  end
end
