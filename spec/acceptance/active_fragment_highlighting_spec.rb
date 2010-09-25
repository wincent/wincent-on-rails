require File.expand_path('acceptance_helper', File.dirname(__FILE__))

feature 'active fragment highlighting' do
  let(:commentable) { Article.make! :title => 'foo' }
  let(:comment) { Comment.make! :commentable => commentable, :body => 'hello' }

  scenario 'visiting a comment', :js => true do
    visit comment_path(comment)
    page.should have_css("\#comment_#{comment.id}.active-fragment")
  end
end
