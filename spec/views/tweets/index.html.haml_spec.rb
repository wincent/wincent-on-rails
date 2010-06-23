require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe '/tweets/index.html.haml' do
  include TweetsHelper

  def do_render
    assigns[:paginator] = @paginator
    assigns[:tweets] = [ create_tweet, create_tweet ]
    render '/tweets/index.html.haml'
  end

  before do
    @paginator = RestfulPaginator.new({}, 2, tweets_path, 20)
  end

  it 'should include an Atom feed link' do
    template.should_receive(:atom_link)
    do_render
  end

  it 'should include pagination links (top and bottom)' do
    @paginator = mock(RestfulPaginator)
    @paginator.should_receive(:pagination_links).twice
    do_render
  end

  it 'should render the "tweets" partial' do
    template.should_receive(:render).with('tweets.html.haml')
    do_render
  end
end
