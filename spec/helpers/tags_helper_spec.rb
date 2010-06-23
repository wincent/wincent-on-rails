require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe TagsHelper, 'taggable_link method' do
  it 'should work with article models' do
    article = create_article
    helper.taggable_link(article).should == link_to(article.title, article_path(article))
  end

  it 'should work with issue models' do
    issue = create_issue
    helper.taggable_link(issue).should == link_to(issue.summary, issue_path(issue))
  end

  it 'should work with post models' do
    post = create_post
    helper.taggable_link(post).should == link_to(post.title, post_path(post))
  end

  it 'should work with topic models' do
    topic = create_topic
    helper.taggable_link(topic).should == link_to(topic.title, forum_topic_path(topic.forum, topic))
  end
end
