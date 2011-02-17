require 'spec_helper'

describe ApplicationHelper, 'timeinfo method' do
  before do
    @model = stub!.created_at { 2.days.ago }.subject
    stub(@model).updated_at { 3.days.ago }
  end

  it 'should get the creation date' do
    mock(@model).created_at { Time.now }
    timeinfo @model
  end

  it 'should get update date' do
    mock(@model).updated_at { Time.now }
    timeinfo @model
  end

  it 'should return just the creation date if update and creation date are the same (exact match)' do
    date = 2.days.ago
    mock(@model).created_at { date }
    mock(@model).updated_at { date }
    timeinfo(@model).should =~ /#{Regexp.escape date.to_s}/
  end

  it 'should return just the creation date if update and creation date are the same (fuzzy match)' do
    earlier_date  = (2.days + 2.hours).ago
    later_date    = (2.days + 1.hour).ago
    mock(@model).created_at { earlier_date }
    mock(@model).updated_at { later_date }
    earlier_date.distance_in_words.should == later_date.distance_in_words # check our assumption about fuzzy equality
    timeinfo(@model).should =~ /#{Regexp.escape earlier_date.to_s}/
  end

  it 'should return both creation and edit date if different' do
    earlier_date  = 3.hours.ago
    later_date    = 1.hour.ago
    mock(@model).created_at { earlier_date }
    mock(@model).updated_at { later_date }
    earlier_date.distance_in_words.should_not == later_date.distance_in_words # check our assumption about inequality
    info = timeinfo(@model)
    info.should =~ /Created.+#{Regexp.escape earlier_date.to_s}/
    info.should =~ /updated.+#{Regexp.escape later_date.to_s}/
  end

  it 'should allow you to override the "updated" string' do
    # for some model types, it might sound better to say "edited" rather than updated
    earlier_date  = 3.hours.ago
    later_date    = 1.hour.ago
    mock(@model).created_at { earlier_date }
    mock(@model).updated_at { later_date }
    info = timeinfo(@model, :updated_string => 'edited')
    info.should =~ /Created.+#{Regexp.escape earlier_date.to_s}/
    info.should =~ /edited.+#{Regexp.escape later_date.to_s}/
  end

  it 'should not show the "updated" date at all if "updated_string" is set to false' do
    earlier_date  = 3.hours.ago
    later_date    = 1.hour.ago
    mock(@model).created_at { earlier_date }
    mock(@model).updated_at { later_date }
    info = timeinfo @model, :updated_string => false
    info.should =~ /#{Regexp.escape earlier_date.to_s}/
    info.should_not =~ /#{Regexp.escape later_date.to_s}/
  end
end

describe ApplicationHelper, 'product_options method' do
  it 'should find all products' do
    mock(Product).categorized { Hash.new }
    product_options
  end

  it 'should return an array of name/id pairs' do
    Product.delete_all
    product1 = Product.make! :name => 'foo'
    product2 = Product.make! :name => 'bar'
    product_options.should == [[nil, [["foo", product1.id], ["bar", product2.id]]]]
  end
end

describe ApplicationHelper, 'underscores_to_spaces method' do
  it 'should return an array of name/id pairs' do
    hash = { 'foo' => 1, 'bar' => 2 }
    underscores_to_spaces(hash).should =~ [['foo', 1], ['bar', 2]]
  end

  it 'should convert underscores to spaces' do
    hash = { 'foo_bar' => 1, 'baz_bar' => 2 }
    underscores_to_spaces(hash).should =~ [['foo bar', 1], ['baz bar', 2]]
  end

  it 'should convert symbol-based keys to strings' do
    hash = { :foo => 1, :bar => 2 }
    underscores_to_spaces(hash).should =~ [['foo', 1], ['bar', 2]]
  end
end

describe ApplicationHelper, '"button_to_moderate_issue_as_ham" method' do
  include ApplicationHelper
  before do
    @issue = Issue.make!
  end

  it 'should call the "button_to_moderate_model_as_ham" method' do
    mock(self).button_to_moderate_model_as_ham(@issue, issue_path(@issue))
    button_to_moderate_issue_as_ham @issue
  end
end

describe ApplicationHelper, '"link_to_commentable" method' do

  # was a bug
  it 'should adequately escape HTML special characters (Issue summaries)' do
    issue = Issue.make! :summary => '<em>foo</em>'
    link_to_commentable(issue).should_not =~ /<em>/
  end
end

describe ApplicationHelper, '"tweet_title" method' do
  it 'should strip HTML tags' do
    tweet = Tweet.make :body => "foo ''bar''"
    tweet_title(tweet).should =~ /foo bar/
  end

  it 'should compress whitespace' do
    tweet = Tweet.make :body => "foo    bar   \n   baz"
    tweet_title(tweet).should =~ /foo bar baz/
  end

  it 'should remove leading whitespace' do
    tweet = Tweet.make :body => "  foo\n  bar"
    tweet_title(tweet).should =~ /\Afoo bar/
  end

  it 'should remove trailing whitespace' do
    tweet = Tweet.make :body => "foo  \nbar  "
    tweet_title(tweet).should =~ /foo bar\z/
  end

  it 'should truncate long text to 80 characters' do
    tweet = Tweet.make :body => 'x' * 100
    tweet_title(tweet).length.should == 80
  end
end

describe ApplicationHelper do
  describe '#breadcrumbs' do
    it 'returns an HTML-safe string' do
      breadcrumbs('foo').should be_html_safe
    end

    it 'escapes non-HTML-safe strings' do
      breadcrumbs('"foo"').should match(/&quot;foo&quot;/)
    end

    # was a regression, introduced in the move from Rails 3.0.1 to 3.0.3
    it 'does not escape links' do
      # link_to returns HTML-safe strings, so mimic it
      breadcrumbs('<a href="/foo">'.html_safe, 'bar').should match(%r{<a href="/foo">})
    end

    # was a regression, introduced in the move from Rails 3.0.1 to 3.0.3
    it 'does not inappropriately escape "raquo" entities' do
      breadcrumbs('foo').should match(/&raquo;/)
    end
  end

  describe '#commit_abbrev' do
    it 'returns the first 16 characters of the hash' do
      commit_abbrev('1234abcd1234abcd999999999999999999999999').
        should == '1234abcd1234abcd'
    end
  end

  describe '#commit_author_time' do
    pending
  end

  describe '#commit_committer_time' do
    pending
  end

  describe '#stylesheet_link_tags' do
    describe 'regressions' do
      it 'does not pluralize the dashboard controller' do
        stub(helper).controller.stub!.class { DashboardController }
        tags = helper.stylesheet_link_tags
        tags.should_not match('dashboards.css')
        tags.should match('dashboard.css')
      end
    end
  end

  describe '#link_to_model' do
    it 'works with article models' do
      article = Article.make!
      link = link_to(article.title, article_path(article))
      link_to_model(article).should == link
    end

    it 'works with issue models' do
      issue = Issue.make!
      link_to_model(issue).should == link_to(issue.summary, issue_path(issue))
    end

    it 'works with post models' do
      post = Post.make!
      link_to_model(post).should == link_to(post.title, post_path(post))
    end

    it 'works with topic models' do
      topic = Topic.make!
      link = link_to(topic.title, forum_topic_path(topic.forum, topic))
      link_to_model(topic).should == link
    end
  end

  describe '#wikitext_truncate_and_strip' do
    it 'strips out wikitext markup' do
      wikitext_truncate_and_strip("''fun''").should == 'fun' # quotes are gone
    end

    it 'truncates long output' do
      wikitext_truncate_and_strip('long long long', :length => 10).
        should == 'long lo...'
    end

    it 'marks output as HTML-safe' do
      output = wikitext_truncate_and_strip 'foo & bar'
      output.should be_html_safe        # it is marked as safe
      output.should == 'foo &amp; bar'  # and it really is safe
    end

    it 'applies any custom "omission" option' do
      output = wikitext_truncate_and_strip 'foo, bar, baz, bing, bong',
        :length => 18, :omission => '[snip]'
      output.should == 'foo, bar, ba[snip]'
    end

    context 'truncation which cuts an entity in half' do
      it 'removes the mangled entity' do
        output = wikitext_truncate_and_strip 'foo, bar & baz', :length => 14
        output.should == 'foo, bar ...' # safe output
        output.should be_html_safe      # and marked as such
      end
    end

    context 'truncation which leaves entities intact' do
      it 'marks the output as HTML safe' do
        output = wikitext_truncate_and_strip 'foo & bar etc', :length => 15
        output.should == 'foo &amp; ba...'  # safe output
        output.should be_html_safe          # and marked as such
      end
    end
  end
end
