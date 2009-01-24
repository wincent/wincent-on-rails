require File.dirname(__FILE__) + '/../spec_helper'

describe TagsHelper, 'taggable_link method' do
  it 'should work with article models' do
    article = create_article
    helper.taggable_link(article).should == link_to(h(article.title), article_url(article))
  end

  it 'should work with issue models' do
    issue = create_issue
    helper.taggable_link(issue).should == link_to(h(issue.summary), issue_url(issue))
  end

  it 'should work with post models' do
    post = create_post
    helper.taggable_link(post).should == link_to(h(post.title), post_url(post))
  end

  it 'should work with topic models' do
    topic = create_topic
    helper.taggable_link(topic).should == link_to(h(topic.title), forum_topic_url(topic.forum, topic))
  end
end
