require File.dirname(__FILE__) + '/../spec_helper'

describe Needle do
  before(:each) do
    @needle = Needle.new
  end

  it "should be valid" do
    @needle.should be_valid
  end
end

describe Needle::NeedleQuery do
  # unfortunately this spec is tied fairly intimately to Rails' specific way of preparing queries
  # (use of backticks, for example; and witness the breakage in Rails 2.1.0_RC1: the change in the output order)
  # even so it is still the easiest way to test the class
  it 'should handle a complex example' do
    input = "title:foo bar http://example.com/ body:http://example.org bad: don't body:body-building :badder"
    query = Needle::NeedleQuery.new(input)
    query.prepare_clauses
    query.clauses.should == [
      "`needles`.`content` = 'foo' AND `needles`.`attribute_name` = 'title'",
      "`needles`.`content` = 'bar'",
      "`needles`.`content` = 'http://example.com/'",
      "`needles`.`content` = 'http://example.org' AND `needles`.`attribute_name` = 'body'",
      "`needles`.`content` = 'bad'",
      "`needles`.`content` = 'don'",
      "`needles`.`content` = 'body' AND `needles`.`attribute_name` = 'body'",
      "`needles`.`content` = 'building' AND `needles`.`attribute_name` = 'body'",
      "`needles`.`content` = 'badder'"
      ]
  end
end

describe Needle, 'searching' do
  before do
    10.times { create_article; create_issue; create_post; create_topic; } # we'll be looking for needles in this "haystack"
  end

  it 'should find articles (words in the title)' do
    needle = create_article :title => 'abc xyz'
    Needle.find_using_query_string('xyz').should == [needle]
  end

  it 'should find articles (words in the body)' do
    needle = create_article :body => 'this that'
    Needle.find_using_query_string('this').should == [needle]
  end

  it 'should find issues (words in the summary)' do
    needle = create_issue :summary => 'abc xyz'
    Needle.find_using_query_string('xyz').should == [needle]
  end

  it 'should find issues (words in the description)' do
    needle = create_issue :description => 'this that'
    Needle.find_using_query_string('this').should == [needle]
  end

  it 'should find posts (words in the excerpt)' do
    needle = create_post :excerpt => 'foo bar baz'
    Needle.find_using_query_string('bar').should == [needle]
  end

  it 'should find posts (words in the title)' do
    needle = create_post :title => 'abc xyz'
    Needle.find_using_query_string('xyz').should == [needle]
  end

  it 'should find posts (words in the body)' do
    needle = create_post :body => 'this that'
    Needle.find_using_query_string('this').should == [needle]
  end

  it 'should find topics (words in the title)' do
    needle = create_topic :title => 'abc xyz'
    Needle.find_using_query_string('xyz').should == [needle]
  end

  it 'should find topics (words in the body)' do
    needle = create_topic :body => 'this that'
    Needle.find_using_query_string('this').should == [needle]
  end

  it 'should find URLs' do
    needle = create_post :body => 'foo http://example.com/ bar'
    Needle.find_using_query_string('http://example.com/').should == [needle]
  end

  it 'should find email addresses' do
    needle = create_issue :description => 'foo user@example.com bar'
    Needle.find_using_query_string('user@example.com').should == [needle]
  end

  it 'should not find wikitext markup' do
    needle = create_topic :body => '<nowiki>[[foo]]</nowiki>'
    Needle.find_using_query_string('<nowiki>').should == []
    Needle.find_using_query_string('nowiki').should == []
    Needle.find_using_query_string('foo').should == [needle]
  end

  it 'should not find non-alphanumeric characters' do
    create_post :body => 'áéíóú foo'
    Needle.find_using_query_string('áéíóú').should == []

    # but note how this still works because it is indexed and searched for as "informaci", "ling", and "stica"
    needle = create_post :body => 'información lingüística'
    Needle.find_using_query_string('información lingüística').should == [needle]
  end

  it 'should find results of different types' do
    needle1 = create_topic :title => 'foo bar baz'
    needle2 = create_issue :description => 'bar abc'
    needle3 = create_article :body => 'that bar'
    needle4 = create_post :excerpt => 'this bar'
    Needle.find_using_query_string('bar').to_set.should == [needle1, needle2, needle3, needle4].to_set
  end

  it 'should find posts with an implicit "OR" style search' do
    needle = create_post :excerpt => 'foo bar baz'
    Needle.find_using_query_string('this foo that').should == [needle]
  end

  it 'should find posts with an explicit "OR" style search' do
    needle = create_post :excerpt => 'foo bar baz'
    Needle.find_using_query_string('this foo that', :type => :or).should == [needle]
  end

  it 'should find posts with an "AND" style search' do
    needle  = create_article :body => 'foo bar baz'
    hay     = create_issue :summary => 'foo bar'
    Needle.find_using_query_string('foo bar baz', :type => :and).should == [needle]
  end

  it 'should ignore "OR" clauses in excess of the 10-clause limit' do
    create_article :body => 'eleven'
    Needle.find_using_query_string('one two three four five six seven eight nine ten eleven').should == []
  end

  it 'should ignore "AND" clauses in excess of the 5-clause limit' do
    needle = create_post :body => 'one two three four five six'
    Needle.find_using_query_string('one two three four five ignored', :type => :and).should == [needle]
  end

  it 'should order search results by relevance' do
    needle1 = create_issue :summary => 'foo'
    needle2 = create_topic :title => 'foo was foo or foo', :body => 'all about foo and foo'
    needle3 = create_post :excerpt => 'foo and more foo'
    Needle.find_using_query_string('foo').should == [needle2, needle3, needle1]
  end

  it 'should return no more than 21 rows at a time (20 + 1 as a pagination hint)' do
    25.times { create_issue :summary => 'foo' }
    Needle.find_using_query_string('foo').length.should == 21
  end

  it 'should accept an offset parameter for the purposes of pagination' do
    20.times { create_topic :title => 'really really really relevant' } # first page
    needle = create_post :title => 'really quite relevant'              # overflow on second page
    Needle.find_using_query_string('really', :offset => 20).should == [needle]
  end

  it 'should find posts with attribute-based criteria' do
    needle = create_post :title => 'hello world', :body => 'foo bar baz'
    Needle.find_using_query_string('title:foo').should == []
    Needle.find_using_query_string('body:bar').should == [needle]
  end

  it 'should not find topics which are awaiting moderation' do
    create_topic :title => 'what you are looking for', :awaiting_moderation => true
    Needle.find_using_query_string('looking').should == []
  end

  it 'should find topics once they have been marked as ham' do
    needle = create_topic :body => 'was hidden', :awaiting_moderation => true
    needle.moderate_as_ham!
    Needle.find_using_query_string('hidden').should == [needle]
  end

  it 'should not find spam topics' do
    create_topic :body => 'the content', :spam => true
    Needle.find_using_query_string('looking').should == []
  end

  it 'should not find issues which are awaiting moderation' do
    create_issue :summary => 'what you are looking for', :awaiting_moderation => true
    Needle.find_using_query_string('looking').should == []
  end

  it 'should find issues once they have been marked as ham' do
    needle = create_issue :description => 'was hidden', :awaiting_moderation => true
    needle.moderate_as_ham!
    Needle.find_using_query_string('hidden').should == [needle]
  end

  it 'should not find spam issues' do
    create_issue :description => 'the content', :spam => true
    Needle.find_using_query_string('looking').should == []
  end

  it 'should not find issues which have been destroyed' do
    issue = create_issue :summary => 'foo'
    issue.destroy
    Needle.find_using_query_string('foo').should == []
  end

  it 'should not find issues which have been deleted' do
    issue = create_issue :summary => 'foo'
    Issue.delete issue.id # no callbacks fire here, so the search index gets out of date
    Needle.find_using_query_string('foo').should == [nil]
  end

  it 'should log a warning for missing records' do
    issue = create_issue :summary => 'foo'
    Issue.delete issue.id # no callbacks fire here, so the search index gets out of date
    logger = Needle.logger
    begin
      Needle.logger = mock_logger = mock('Logger', :null_object => true)
      mock_logger.should_receive(:warn).with(/search index out of date/i)
      Needle.find_using_query_string('foo')
    ensure
      Needle.logger = logger
    end
  end
end

describe Needle, 'searching as a superuser' do
  before do
    @admin = create_user :superuser => true
  end

  it 'should find private articles' do
    needle = create_article :title => 'confidential', :public => false
    Needle.find_using_query_string('confidential', :user => @admin).should == [needle]
  end

  it 'should find private issues' do
    needle = create_issue :summary => 'confidential', :public => false
    Needle.find_using_query_string('confidential', :user => @admin).should == [needle]
  end

  it 'should find private posts' do
    needle = create_post :title => 'confidential', :public => false
    Needle.find_using_query_string('confidential', :user => @admin).should == [needle]
  end

  it 'should find private topics' do
    needle = create_topic :title => 'confidential', :public => false
    Needle.find_using_query_string('confidential', :user => @admin).should == [needle]
  end
end

describe Needle, 'searching as an unprivileged user' do
  before do
    @user = create_user :superuser => false
  end

  it "should not find private articles" do
    needle = create_article :title => 'confidential', :public => false
    Needle.find_using_query_string('confidential', :user => @user).should == []
  end

  it "should not find other users' private issues" do
    needle = create_issue :summary => 'confidential', :public => false
    Needle.find_using_query_string('confidential', :user => @user).should == []
  end

  it "should not find private posts" do
    needle = create_post :title => 'confidential', :public => false
    Needle.find_using_query_string('confidential', :user => @user).should == []
  end

  it "should not find other users' private topics" do
    needle = create_topic :title => 'confidential', :public => false
    Needle.find_using_query_string('confidential', :user => @user).should == []
  end

  it 'should find own private issues' do
    needle = create_issue :summary => 'confidential', :public => false, :user => @user
    Needle.find_using_query_string('confidential', :user => @user).should == [needle]
  end

  it 'should find own private topics' do
    needle = create_topic :title => 'confidential', :public => false, :user => @user
    Needle.find_using_query_string('confidential', :user => @user).should == [needle]
  end
end

describe Needle, 'searching as an anonymous user' do
  it 'should not find private articles' do
    needle = create_article :title => 'confidential', :public => false
    Needle.find_using_query_string('confidential').should == []
  end

  it 'should not find private issues' do
    needle = create_issue :summary => 'confidential', :public => false
    Needle.find_using_query_string('confidential').should == []
  end

  it 'should not find private posts' do
    needle = create_post :title => 'confidential', :public => false
    Needle.find_using_query_string('confidential').should == []
  end

  it 'should not find private topics' do
    needle = create_topic :title => 'confidential', :public => false
    Needle.find_using_query_string('confidential').should == []
  end
end
