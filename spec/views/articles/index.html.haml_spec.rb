require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe "/articles/index.html.haml" do
  include ArticlesHelper

  before(:each) do
    #article_98 = mock_model(Article)
    #article_99 = mock_model(Article)
    #assigns[:articles] = [article_98, article_99]
  end

  it "should render list of articles" do
    #render "/articles/index.html.haml"
  end
end

