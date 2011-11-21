require 'spec_helper'

describe 'tweets/new.html.haml' do
  before do
    @tweet = Tweet.new
  end

  it 'displays error messages' do
    stub.proxy(view).render
    mock(view).render('shared/error_messages', anything)
    render
  end

  it 'has a form for the tweet' do
    render
    rendered.should have_css('form[method=post]', :action => '/twitter')
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
    stub.proxy(view).render
    mock(view).render('preview.html.haml')
    render
  end

  it 'has a link to the tweets index' do
    render
    rendered.should have_css('.links a', :href => '/twitter')
  end
end
