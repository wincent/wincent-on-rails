require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'tweets/edit.html.haml' do
  before do
    @tweet = Tweet.make! :body => 'hello'
    assigns[:tweet] = @tweet
    stub(view).render 'shared/error_messages', :model => @tweet
    stub(view).render 'preview'
    stub.proxy(view).render
  end

  it 'includes "ajax.js"' do
    mock(view).javascript_include_tag 'ajax'
    render
  end

  it 'renders the error messages partial' do
    mock(view).render 'shared/error_messages', :model => @tweet
    render
  end

  it 'has a form for the tweet' do
    render
    rendered.should have_selector("form[action='#{tweet_path @tweet}'][method=post]") do |form|
      # real HTTP PUT is not supported, the form is just a normal POST
      # with a hidden field faking the PUT
      form.should have_selector('input[name=_method][value=put]')
      form.should have_selector("textarea[name='tweet[body]']", :content => 'hello')
    end
  end

  it 'provides a link to the wikitext cheatsheet' do
    mock(view).wikitext_cheatsheet
    render
  end

  it 'has a preview div' do
    render
    rendered.should have_selector('#preview')
  end

  it 'renders the preview partial' do
    mock(view).render 'preview'
    render
  end

  it 'has a "show" link' do
    render
    rendered.should have_selector('.links') do |div|
      div.should have_selector("a[href='#{tweet_path(@tweet)}']")
    end
  end

  it 'has a "destroy" link' do
    render
    rendered.should have_selector('.links') do |div|
      div.should have_selector("form[action='#{tweet_path(@tweet)}'] input[name=_method][value=delete]")
    end
  end

  it 'has a link to the tweets index' do
    render
    rendered.should have_selector(".links a[href='/twitter']")
  end
end
