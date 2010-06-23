require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe "/articles/new.html.haml" do
  include ArticlesHelper

  before(:each) do
    #@article = mock_model(Article)
    #@article.stub!(:new_record?).and_return(true)
    #assigns[:article] = @article
  end

  it "should render new form" do
    #render "/articles/new.html.haml"
    pending
    response.should have_tag("form[action=?][method=post]", articles_path) do
    end
  end
end


