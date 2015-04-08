# encoding: utf-8
require 'spec_helper'

describe Needle::NeedleQuery do
  # unfortunately this spec is tied fairly intimately to Rails' specific way of
  # preparing queries even so it is still the easiest way to test the class
  it 'should handle a complex example' do
    input = "title:foo bar http://example.com/ body:http://example.org bad: don't body:body-building :badder"
    query = Needle::NeedleQuery.new(input)
    query.prepare_clauses
    expect(query.clauses).to eq([
      "content = 'foo' AND attribute_name = 'title'",
      "content = 'bar'",
      "content = 'http://example.com/'",
      "content = 'http://example.org' AND attribute_name = 'body'",
      "content = 'bad'",
      "content = 'don'",
      "content = 'body' AND attribute_name = 'body'",
      "content = 'building' AND attribute_name = 'body'",
      "content = 'badder'",
    ])
  end
end

describe Needle do
  describe '#model_class' do
    it 'defaults to nil' do
      expect(Needle.new.model_class).to be_nil
    end
  end

  describe '#model_id' do
    it 'defaults to nil' do
      expect(Needle.new.model_id).to be_nil
    end
  end

  describe '#attribute_name' do
    it 'defaults to nil' do
      expect(Needle.new.attribute_name).to be_nil
    end
  end

  describe '#content' do
    it 'defaults to nil' do
      expect(Needle.new.content).to be_nil
    end
  end

  describe '#user_id' do
    it 'defaults to nil' do
      expect(Needle.new.user_id).to be_nil
    end
  end

  describe '#public' do
    it 'defaults to nil' do
      # possible values are true, false and nil
      # (where nil stands for "not applicable")
      expect(Needle.new.public).to be_nil
    end
  end
end

# :model_class, :model_id, :attribute_name, :content, :user_id, :public
describe Needle, 'accessible attributes' do
  it 'should allow mass-assignment to the model class' do
    expect(Needle.make(:model_class => 'Post')).to allow_mass_assignment_of(:model_class => 'Issue')
  end

  it 'should allow mass-assignment to the model id' do
    expect(Needle.make).to allow_mass_assignment_of(:model_id => 320)
  end

  it 'should allow mass-assignment to the attribute name' do
    expect(Needle.make(:attribute_name => 'body')).to allow_mass_assignment_of(:attribute_name => 'summary')
  end

  it 'should allow mass-assignment to the content' do
    expect(Needle.make).to allow_mass_assignment_of(:content => 'foobarbaz')
  end

  it 'should allow mass-assignment to the user id' do
    expect(Needle.make).to allow_mass_assignment_of(:user_id => 125)
  end

  it 'should allow mass-assignment to the public attribute' do
    expect(Needle.make(:public => false)).to allow_mass_assignment_of(:public => true)
  end
end

describe Needle, 'protected attributes' do
  # this model doesn't have any protected attributes
end

describe Needle, 'searching' do
  before do
    10.times { Article.make!; Issue.make!; Post.make!; Topic.make!; } # we'll be looking for needles in this "haystack"
  end

  it 'should find articles (words in the title)' do
    needle = Article.make! :title => 'abc xyz'
    expect(Needle.find_with_query_string('xyz')).to eq([needle])
  end

  it 'should find articles (words in the body)' do
    needle = Article.make! :body => 'this that'
    expect(Needle.find_with_query_string('this')).to eq([needle])
  end

  it 'should find issues (words in the summary)' do
    needle = Issue.make! :summary => 'abc xyz'
    expect(Needle.find_with_query_string('xyz')).to eq([needle])
  end

  it 'should find issues (words in the description)' do
    needle = Issue.make! :description => 'this that'
    expect(Needle.find_with_query_string('this')).to eq([needle])
  end

  it 'should find posts (words in the excerpt)' do
    needle = Post.make! :excerpt => 'foo bar baz'
    expect(Needle.find_with_query_string('bar')).to eq([needle])
  end

  it 'should find posts (words in the title)' do
    needle = Post.make! :title => 'abc xyz'
    expect(Needle.find_with_query_string('xyz')).to eq([needle])
  end

  it 'should find posts (words in the body)' do
    needle = Post.make! :body => 'this that'
    expect(Needle.find_with_query_string('this')).to eq([needle])
  end

  it 'should find topics (words in the title)' do
    needle = Topic.make! :title => 'abc xyz'
    expect(Needle.find_with_query_string('xyz')).to eq([needle])
  end

  it 'should find topics (words in the body)' do
    needle = Topic.make! :body => 'this that'
    expect(Needle.find_with_query_string('this')).to eq([needle])
  end

  it 'should find URLs' do
    needle = Post.make! :body => 'foo http://example.com/ bar'
    expect(Needle.find_with_query_string('http://example.com/')).to eq([needle])
  end

  it 'should find email addresses' do
    needle = Issue.make! :description => 'foo user@example.com bar'
    expect(Needle.find_with_query_string('user@example.com')).to eq([needle])
  end

  it 'should not find wikitext markup' do
    needle = Topic.make! :body => '<nowiki>[[foo]]</nowiki>'
    expect(Needle.find_with_query_string('<nowiki>')).to eq([])
    expect(Needle.find_with_query_string('nowiki')).to eq([])
    expect(Needle.find_with_query_string('foo')).to eq([needle])
  end

  it 'should not find non-alphanumeric characters' do
    Post.make! :body => 'áéíóú foo'
    expect(Needle.find_with_query_string('áéíóú')).to eq([])

    # but note how this still works because it is indexed and searched for as "informaci", "ling", and "stica"
    needle = Post.make! :body => 'información lingüística'
    expect(Needle.find_with_query_string('información lingüística')).to eq([needle])
  end

  it 'should find results of different types' do
    needle1 = Topic.make! :title => 'foo bar baz'
    needle2 = Issue.make! :description => 'bar abc'
    needle3 = Article.make! :body => 'that bar'
    needle4 = Post.make! :excerpt => 'this bar'
    expect(Needle.find_with_query_string('bar').to_set).to eq([needle1, needle2, needle3, needle4].to_set)
  end

  it 'should find posts with an implicit "OR" style search' do
    needle = Post.make! :excerpt => 'foo bar baz'
    expect(Needle.find_with_query_string('this foo that')).to eq([needle])
  end

  it 'should find posts with an explicit "OR" style search' do
    needle = Post.make! :excerpt => 'foo bar baz'
    expect(Needle.find_with_query_string('this foo that', :type => :or)).to eq([needle])
  end

  it 'should find posts with an "AND" style search' do
    needle  = Article.make! :body => 'foo bar baz'
    hay     = Issue.make! :summary => 'foo bar'
    expect(Needle.find_with_query_string('foo bar baz', :type => :and)).to eq([needle])
  end

  it 'should ignore "OR" clauses in excess of the 10-clause limit' do
    Article.make! :body => 'eleven'
    expect(Needle.find_with_query_string('one two three four five six seven eight nine ten eleven')).to eq([])
  end

  it 'should ignore "AND" clauses in excess of the 5-clause limit' do
    needle = Post.make! :body => 'one two three four five six'
    expect(Needle.find_with_query_string('one two three four five ignored', :type => :and)).to eq([needle])
  end

  it 'should order search results by relevance' do
    needle1 = Issue.make! :summary => 'foo'
    needle2 = Topic.make! :title => 'foo was foo or foo', :body => 'all about foo and foo'
    needle3 = Post.make! :excerpt => 'foo and more foo'
    expect(Needle.find_with_query_string('foo')).to eq([needle2, needle3, needle1])
  end

  it 'should return no more than 21 rows at a time (20 + 1 as a pagination hint)' do
    25.times { Issue.make! :summary => 'foo' }
    expect(Needle.find_with_query_string('foo').length).to eq(21)
  end

  it 'should accept an offset parameter for the purposes of pagination' do
    20.times { Topic.make! :title => 'really really really relevant' } # first page
    needle = Post.make! :title => 'really quite relevant'              # overflow on second page
    expect(Needle.find_with_query_string('really', :offset => 20)).to eq([needle])
  end

  it 'should find posts with attribute-based criteria' do
    needle = Post.make! :title => 'hello world', :body => 'foo bar baz'
    expect(Needle.find_with_query_string('title:foo')).to eq([])
    expect(Needle.find_with_query_string('body:bar')).to eq([needle])
  end

  it 'should not find topics which are awaiting moderation' do
    Topic.make! :title => 'what you are looking for', :awaiting_moderation => true
    expect(Needle.find_with_query_string('looking')).to eq([])
  end

  it 'should find topics once they have been marked as ham' do
    needle = Topic.make! :body => 'was hidden', :awaiting_moderation => true
    needle.moderate_as_ham!
    expect(Needle.find_with_query_string('hidden')).to eq([needle])
  end

  it 'should not find issues which are awaiting moderation' do
    Issue.make! :summary => 'what you are looking for', :awaiting_moderation => true
    expect(Needle.find_with_query_string('looking')).to eq([])
  end

  it 'should find issues once they have been marked as ham' do
    needle = Issue.make! :description => 'was hidden', :awaiting_moderation => true
    needle.moderate_as_ham!
    expect(Needle.find_with_query_string('hidden')).to eq([needle])
  end

  it 'should not find issues which have been destroyed' do
    issue = Issue.make! :summary => 'foo'
    issue.destroy
    expect(Needle.find_with_query_string('foo')).to eq([])
  end

  it 'should not find issues which have been deleted' do
    issue = Issue.make! :summary => 'foo'
    Issue.delete issue.id # no callbacks fire here, so the search index gets out of date
    expect(Needle.find_with_query_string('foo')).to eq([nil])
  end

  it 'should log a warning for missing records' do
    issue = Issue.make! :summary => 'foo'
    Issue.delete issue.id # no callbacks fire here, so the search index gets out of date
    mock(Needle.logger).warn /search index out of date/i
    Needle.find_with_query_string('foo')
  end
end

describe Needle, 'searching as a superuser' do
  before do
    @admin = User.make! :superuser => true
  end

  it 'should find private articles' do
    needle = Article.make! :title => 'confidential', :public => false
    expect(Needle.find_with_query_string('confidential', :user => @admin)).to eq([needle])
  end

  it 'should find private issues' do
    needle = Issue.make! :summary => 'confidential', :public => false
    expect(Needle.find_with_query_string('confidential', :user => @admin)).to eq([needle])
  end

  it 'should find private posts' do
    needle = Post.make! :title => 'confidential', :public => false
    expect(Needle.find_with_query_string('confidential', :user => @admin)).to eq([needle])
  end

  it 'should find private topics' do
    needle = Topic.make! :title => 'confidential', :public => false
    expect(Needle.find_with_query_string('confidential', :user => @admin)).to eq([needle])
  end
end

describe Needle, 'searching as an unprivileged user' do
  before do
    @user = User.make! :superuser => false
  end

  it "should not find private articles" do
    needle = Article.make! :title => 'confidential', :public => false
    expect(Needle.find_with_query_string('confidential', :user => @user)).to eq([])
  end

  it "should not find other users' private issues" do
    needle = Issue.make! :summary => 'confidential', :public => false
    expect(Needle.find_with_query_string('confidential', :user => @user)).to eq([])
  end

  it "should not find private posts" do
    needle = Post.make! :title => 'confidential', :public => false
    expect(Needle.find_with_query_string('confidential', :user => @user)).to eq([])
  end

  it "should not find other users' private topics" do
    needle = Topic.make! :title => 'confidential', :public => false
    expect(Needle.find_with_query_string('confidential', :user => @user)).to eq([])
  end

  it 'should find own private issues' do
    needle = Issue.make! :summary => 'confidential', :public => false, :user => @user
    expect(Needle.find_with_query_string('confidential', :user => @user)).to eq([needle])
  end

  it 'should find own private topics' do
    needle = Topic.make! :title => 'confidential', :public => false, :user => @user
    expect(Needle.find_with_query_string('confidential', :user => @user)).to eq([needle])
  end
end

describe Needle, 'searching as an anonymous user' do
  it 'should not find private articles' do
    needle = Article.make! :title => 'confidential', :public => false
    expect(Needle.find_with_query_string('confidential')).to eq([])
  end

  it 'should not find private issues' do
    needle = Issue.make! :summary => 'confidential', :public => false
    expect(Needle.find_with_query_string('confidential')).to eq([])
  end

  it 'should not find private posts' do
    needle = Post.make! :title => 'confidential', :public => false
    expect(Needle.find_with_query_string('confidential')).to eq([])
  end

  it 'should not find private topics' do
    needle = Topic.make! :title => 'confidential', :public => false
    expect(Needle.find_with_query_string('confidential')).to eq([])
  end
end
