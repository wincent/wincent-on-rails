require File.dirname(__FILE__) + '/../spec_helper'

describe Article do
end

describe Article, 'comments association' do
  it 'should respond to the comments message' do
    create_article.comments.should == []
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
end
