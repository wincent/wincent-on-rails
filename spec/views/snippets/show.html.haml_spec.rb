require 'spec_helper'

describe 'snippets/show.html.haml' do
  before do
    @snippet = Snippet.make! :body => 'foo', :description => 'bar'
    @comments = @snippet.comments.published
    @comment = Comment.new
  end

  it 'includes "ajax.js"' do
    mock(view).javascript_include_tag 'ajax'
    render
  end

  it 'shows breadcrumbs' do
    mock(view).breadcrumbs /Snippets/, /bar/
    render
  end

  it 'shows the title' do
    render
    rendered.should have_selector('h1.major', :content => 'bar')
  end

  it 'shows the time information for the snippet' do
    mock(view).timeinfo(@snippet)
    render
  end

  it 'shows a by-line' do
    render
    rendered.should contain("by #{APP_CONFIG['admin_name']}")
  end

  it 'shows the snippet body' do
    render
    rendered.should contain('foo')
  end

  it 'renders the "shared/tags" partial' do
    stub.proxy(view).render.with_any_args
    mock(view).render('shared/tags', anything)
    render
  end

  it 'has a link to the snippets index' do
    render
    rendered.should have_selector('.links a', :href => '/snippets')
  end

  context 'commenting open' do
    it 'displays the comment form' do
      render
      rendered.should have_selector('#comment-form')
    end

    it 'has a submit button' do
      render
      rendered.should have_selector('#comment-form a',
        :href => new_snippet_comment_path(@snippet))
    end
  end

  context 'commenting closed' do
    before do
      @comment = nil
    end

    it 'does not display a comment form' do
      render
      rendered.should_not have_selector('#comment-form')
    end

    it 'provides a link to the forums' do
      render
      rendered.should have_selector('a', :href => '/forums')
    end
  end
end
