require File.expand_path('../acceptance_helper', File.dirname(__FILE__))

# bug fixed in commit 76968b7
feature 'commenting on a wiki article with "strange" characters' do
  background do
    Article.make! :title => 'has <strange> stuff'
    @article_path     = '/wiki/has_%3Cstrange%3E_stuff'
    @comment_path     = '/wiki/has_%3Cstrange%3E_stuff/comments'
    @new_comment_path = '/wiki/has_%3Cstrange%3E_stuff/comments/new'
  end

  scenario 'a title with "strange" characters (AJAX)', :js => true do
    visit @article_path
    page.should_not have_css("form[action='#{@comment_path}']")
    click 'add a comment' # form pulled down via AJAX
    page.should have_css("form[action='#{@comment_path}']")
  end

  scenario 'a title with "strange" characters (no JavaScript)' do
    visit @new_comment_path
    page.should have_css("form[action='#{@comment_path}']")
  end
end
