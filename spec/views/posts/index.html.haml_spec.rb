require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'posts/index' do
  before do
    @tweets = [Tweet.make!]
    @posts  = [Post.make!]
  end

  # was a bug
  it 'does not have nested <p> tags' do
    render
    rendered.should_not match(/<p>\w*<p>/)
  end

  it 'has a link to the tweets Atom feed' do
    render
    rendered.should have_selector('a', :href => tweets_path(:format => :atom))
  end
end
