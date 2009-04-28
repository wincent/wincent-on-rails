require File.dirname(__FILE__) + '/../../spec_helper'

describe '/posts/index.html.haml' do
  include PostsHelper

  before do
    assigns[:tweets] = [create_tweet]
    assigns[:posts]  = [create_post]
  end

  def do_render
    render '/posts/index.html.haml'
  end

  # was a bug
  it 'should not have nested <p> tags' do
    do_render
    response.should_not have_text(/<p>\w*<p>/)
  end

  it 'should have a link to the tweets Atom feed' do
    do_render
    response.should have_tag('a[href=?]', tweets_path(:format => :atom))
  end
end
