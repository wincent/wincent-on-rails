require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe '/tweets/index.html.haml' do
  include TweetsHelper

  def do_render
    assigns[:tweets] = @tweets
    assigns[:paginator] = @paginator
    render '/tweets/index.html.haml'
  end

  before do
    @tweets = [
      create_tweet(:body => "''foo''"),
      create_tweet(:body => "'''bar'''")
    ]
    @paginator = RestfulPaginator.new({}, 2, tweets_url, 20)
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

  it 'should display a div for each tweet' do
    do_render
    response.should have_tag('div.tweet', 2)
  end

  it 'should display the HTML body of each tweet' do
    do_render
    response.body.should =~ %r{<em>foo</em>}
    response.body.should =~ %r{<strong>bar</strong>}
  end

  it 'should show the time information for each tweet' do
    template.should_receive(:timeinfo).with(@tweets[0])
    template.should_receive(:timeinfo).with(@tweets[1])
    do_render
  end

  it 'should show a permalink for each tweet' do
    do_render
    response.should have_tag('a[href=?]', tweet_url(@tweets[0]), 'permalink')
    response.should have_tag('a[href=?]', tweet_url(@tweets[1]), 'permalink')
  end
end
