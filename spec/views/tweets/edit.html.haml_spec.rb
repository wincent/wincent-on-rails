require 'spec_helper'

describe 'tweets/edit.html.haml' do
  before do
    @tweet = Tweet.make! :body => 'hello'
    assigns[:tweet] = @tweet
    stub(view).render 'shared/error_messages', model: @tweet
    stub(view).render 'preview'
    stub.proxy(view).render
  end

  it 'renders the error messages partial' do
    mock(view).render 'shared/error_messages', model: @tweet
    render
  end

  it 'has a form for the tweet' do
    render
    # real HTTP PUT is not supported, the form is just a normal POST
    # with a hidden field faking the PUT
    rendered.should have_css("form[action='#{tweet_path @tweet}'][method=post] input[name=_method][value=put]")
  end

  it 'provides a link to the wikitext cheatsheet' do
    mock(view).wikitext_cheatsheet
    render
  end

  it 'has a preview div' do
    render
    rendered.should have_css('#preview')
  end

  it 'renders the preview partial' do
    mock(view).render 'preview'
    render
  end

  it 'has a "show" link' do
    render
    rendered.should have_css(".links a[href='#{tweet_path(@tweet)}']")
  end

  it 'has a "destroy" link' do
    render
    rendered.should have_css(".links form[action='#{tweet_path(@tweet)}'] input[name=_method][value=delete]")
  end

  it 'has a link to the tweets index' do
    render
    rendered.should have_css(".links a[href='/twitter']")
  end
end
