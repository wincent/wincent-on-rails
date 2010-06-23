require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe "/articles/show.html.haml" do
  include ArticlesHelper

  before(:each) do
    #@article = mock_model(Article)
    #assigns[:article] = @article
  end

  it "should render attributes in <p>" do
    #render "/articles/show.html.haml"
  end
end

