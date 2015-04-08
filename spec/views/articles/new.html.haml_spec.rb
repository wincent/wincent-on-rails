require 'spec_helper'

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
    expect(response).to have_tag("form[action=?][method=post]", articles_path) do
    end
  end
end


