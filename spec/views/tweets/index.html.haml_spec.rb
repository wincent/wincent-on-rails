require 'spec_helper'

describe 'tweets/index.html.haml' do
  before do
    @paginator = RestfulPaginator.new({}, 2, tweets_path, 20)
    assigns[:paginator] = @paginator
    assigns[:tweets] = [ Tweet.make!, Tweet.make! ]
    stub(view).render('tweets.html.haml')
    stub.proxy(view).render
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
