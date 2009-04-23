require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe '/tweets/edit.html.haml' do
  include TweetsHelper

  def do_render
    assigns[:tweet] = @tweet
    render '/tweets/edit.html.haml'
  end

  before do
    @tweet = create_tweet :body => 'hello'
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
    response.should have_tag("form[action=?][method=post]", tweet_url(@tweet)) do
      # real HTTP PUT is not supported, the form is just a normal POST
      # with a hidden field faking the PUT
      with_tag('input[name=_method][value=put]')
      with_tag('textarea[name=?]', 'tweet[body]', 'hello')
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

  it 'should have a "show" link' do
    do_render
    response.should have_tag('.links') do
      # we use Rails shortcut @tweet instead of tweet_url(@tweet)
      # so we end up getting tweet_path(@tweet)
      with_tag 'a[href=?]', tweet_path(@tweet)
    end
  end

  it 'should have a "destroy" link (test HTML)' do
    do_render
    response.should have_tag('.links') do
      # again, using the shortcut gives us tweet_path(@tweet)
      # instead of the habitual tweet_url(@tweet)
      with_tag 'a[href=?]', tweet_path(@tweet), 'destroy'
    end
    # link_to ..., :method => :delete produces some obtrusive JavaScript
    # which unfortunately can't be easily tested
  end

  it 'should have an link to the tweets index' do
    do_render
    response.should have_tag('.links') do
      with_tag 'a[href=?]', tweets_url
    end
  end
end
