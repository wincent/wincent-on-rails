require File.expand_path('../../spec_helper', File.dirname(__FILE__))

describe 'tweets/index.html.haml' do
  before do
    @paginator = RestfulPaginator.new({}, 2, tweets_path, 20)
    assigns[:paginator] = @paginator
    assigns[:tweets] = [ Tweet.make!, Tweet.make! ]
    stub(view).render('tweets.html.haml')
    stub.proxy(view).render
  end

  it 'includes an Atom feed link' do
    mock(view).atom_link('/twitter.atom')
    render
  end

  it 'includes breadcrumbs' do
    mock(view).breadcrumbs 'Twitter'
    render
  end

  it 'includes pagination links (top and bottom)' do
    mock(@paginator).pagination_links.twice
    render
  end

  it 'renders the "tweets" partial' do
    mock(view).render('tweets.html.haml')
    render
  end
end
