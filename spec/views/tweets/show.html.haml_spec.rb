require 'spec_helper'

describe 'tweets/show.html.haml' do
  before do
    @tweet = Tweet.make! body: "''hello''"
    @comments = @tweet.comments.published
    @comment = Comment.new
  end

  it 'shows breadcrumbs' do
    mock(view).breadcrumbs(/Twitter/, /Tweet #/)
    render
  end

  it 'shows the tweet number' do
    render
    rendered.should have_content("Tweet ##{@tweet.id}")
  end

  it 'shows the time information for the tweet' do
    mock(view).timeinfo(@tweet)
    render
  end

  it 'shows a by-line' do
    render
    rendered.should have_content("by #{APP_CONFIG['admin_name']}")
  end

  it 'shows the tweet body as HTML' do
    render
    rendered.should have_css('em', text: 'hello')
  end

  it 'renders the "shared/tags" partial' do
    stub.proxy(view).render.with_any_args # initial render call
    mock(view).render('shared/tags', anything)
    render
  end

  it 'has a link to the tweets index' do
    render
    rendered.should have_link('all tweets', href: '/twitter')
  end

  context 'commenting open' do
    it 'displays the comment form' do
      render
      rendered.should have_css('#comment-form')
    end

    it 'has a submit button' do
      render
      rendered.should have_css("#comment-form a[href='#{new_tweet_comment_path(@tweet)}']")
    end
  end

  context 'commenting closed' do
    before do
      @comment = nil
    end

    it 'does not display a comment form' do
      render
      rendered.should_not have_css('#comment-form')
    end

    it 'provides a link to the forums' do
      render
      rendered.should have_link('forums', href: '/forums')
    end
  end
end
