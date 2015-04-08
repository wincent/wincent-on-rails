require 'spec_helper'

# bug fixed in commit 76968b7
feature 'commenting on a wiki article with "strange" characters' do
  background do
    Article.make! :title => 'has <strange> stuff'
    @article_path     = '/wiki/has_%3Cstrange%3E_stuff'
    @comment_path     = '/wiki/has_%3Cstrange%3E_stuff/comments'
    @new_comment_path = '/wiki/has_%3Cstrange%3E_stuff/comments/new'
  end

  scenario 'a title with "strange" characters (AJAX)', :js do
    visit @article_path
    expect(page).not_to have_css("form[action='#{@comment_path}']")
    click_link 'add a comment' # form pulled down via AJAX
    expect(page).to have_css("form[action='#{@comment_path}']")
  end

  scenario 'a title with "strange" characters (no JavaScript)' do
    visit @new_comment_path
    expect(page).to have_css("form[action='#{@comment_path}']")
  end
end
