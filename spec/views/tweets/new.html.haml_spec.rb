require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe '/tweets/new.html.haml' do
  include TweetsHelper

  def do_render
    assigns[:tweet] = @tweet
    render '/tweets/new.html.haml'
  end

  before do
    @tweet = new_tweet
  end

  it 'should include the "tweets" CSS file' do
    template.should_receive(:stylesheet_link_tag).with('tweets')
    do_render
  end

  it 'should display error messages' do
    template.should_receive(:error_messages_for).with(:tweet)
    do_render
  end

  it 'should have a form for the tweet' do
    do_render
    response.should have_tag("form[action=?][method=post]", tweets_url) do
      with_tag('textarea[name=?]', 'tweet[body]')
    end
  end

  it 'should provide a link to the wikitext cheatsheet' do
    template.should_receive(:wikitext_cheatsheet)
    do_render
  end

  it 'should provide a link for updating the preview' do
    template.should_receive(:link_to_update_preview)
    do_render
  end

  it 'should observe the tweet body (for the preview)' do
    template.should_receive(:observe_body)
    do_render
  end

  it 'should have a preview div' do
    do_render
    response.should have_tag('#preview')
  end

  it 'should render the preview partial' do
    template.should_receive(:render).with('preview.html.haml')
    do_render
  end

  it 'should have an link to the tweets index' do
    do_render
    response.should have_tag('.links') do
      with_tag 'a[href=?]', tweets_url
    end
  end
end
