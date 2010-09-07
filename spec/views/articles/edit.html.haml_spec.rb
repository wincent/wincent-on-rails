require 'spec_helper'

describe "/articles/edit.html.haml" do
  include ArticlesHelper

  before do
    #@article = mock_model(Article)
    #assigns[:article] = @article
  end

  it "should render edit form" do
    #render "/articles/edit.html.haml"
    pending
    response.should have_tag("form[action=#{article_path(@article)}][method=post]") do
    end
  end
end


