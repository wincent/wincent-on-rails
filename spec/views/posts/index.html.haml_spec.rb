require File.dirname(__FILE__) + '/../../spec_helper'

describe "/posts/index.html.haml" do
  include PostsHelper

  before(:each) do
    assigns[:posts] = [create_post]
  end

  # was a bug
  it "should not have nested <p> tags" do
    render "/posts/index.html.haml"
    response.should_not have_text(/<p>\w*<p>/)
  end
end

