require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe TagsHelper, 'taggable_link method' do
  it 'works with article models' do
    article = Article.make!
    link = link_to(article.title, article_path(article))
    taggable_link(article).should == link
  end

  it 'works with issue models' do
    issue = Issue.make!
    taggable_link(issue).should == link_to(issue.summary, issue_path(issue))
  end

  it 'works with post models' do
    post = Post.make!
    taggable_link(post).should == link_to(post.title, post_path(post))
  end

  it 'works with topic models' do
    topic = Topic.make!
    link = link_to(topic.title, forum_topic_path(topic.forum, topic))
    taggable_link(topic).should == link
  end
end
