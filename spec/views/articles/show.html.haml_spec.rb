require 'spec_helper'

describe "/articles/show.html.haml" do
  include ArticlesHelper

  before do
    @article  = Article.make!
    @comments = []
  end

  it "should render attributes in <p>" do
    render
  end
end

