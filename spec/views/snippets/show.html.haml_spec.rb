require 'spec_helper'

describe 'snippets/show.html.haml' do
  before do
    @snippet = Snippet.make! body: 'foo', description: 'bar'
    @comments = @snippet.comments.published
    @comment = Comment.new
  end

  it 'shows breadcrumbs' do
    mock(view).breadcrumbs /Snippets/, /bar/
    render
  end

  it 'shows the title' do
    render
    expect(rendered).to have_css('h1.major', text: 'bar')
  end

  it 'shows the time information for the snippet' do
    mock(view).timeinfo(@snippet)
    render
  end

  it 'shows a by-line' do
    render
    expect(rendered).to have_content("by #{APP_CONFIG['admin_name']}")
  end

  it 'shows the snippet body' do
    render
    expect(rendered).to have_content('foo')
  end

  it 'renders the "shared/tags" partial' do
    stub.proxy(view).render.with_any_args
    mock(view).render('shared/tags', anything)
    render
  end

  it 'has a link to the snippets index' do
    render
    expect(rendered).to have_link('all snippets', href: '/snippets')
  end

  it 'has a link to the raw format for the snippet' do
    render
    expect(rendered).to have_link('raw', href: snippet_path(@snippet, format: :txt))
  end

  context 'commenting open' do
    it 'displays the comment form' do
      render
      expect(rendered).to have_css('#comment-form')
    end

    it 'has a submit button' do
      render
      expect(rendered).to have_link('add a comment',
                                href: new_snippet_comment_path(@snippet))
    end
  end

  context 'commenting closed' do
    before do
      @comment = nil
    end

    it 'does not display a comment form' do
      render
      expect(rendered).not_to have_css('#comment-form')
    end

    it 'provides a link to the forums' do
      render
      expect(rendered).to have_link('forums', href: '/forums')
    end
  end
end
