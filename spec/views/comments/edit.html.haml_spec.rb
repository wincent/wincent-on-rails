require 'spec_helper'

describe 'comments/edit' do
  before do
    @comment = Comment.make!
  end

  it 'has a link back to the commentable model' do
    mock(view).link_to_model @comment.commentable
    render
  end

  it 'has a div for the comment' do
    render
    rendered.should have_css("\#comment_#{@comment.id}")
  end

  it 'has a show button' do
    render
    rendered.should have_link('show', href: comment_path(@comment))
  end

  it 'has a destroy button' do
    mock(view).button_to_destroy_model @comment
    render
  end

  it 'has a ham button if the comment is awaiting moderation' do
    @comment = Comment.make! :awaiting_moderation => true
    mock(view).button_to_moderate_comment_as_ham @comment
    render
  end

  # was a bug
  it 'does not have a ham button if the comment is not awaiting moderation' do
    @comment = Comment.make! :awaiting_moderation => false
    do_not_allow(view).button_to_moderate_comment_as_ham
    render
  end

  it 'has a link back to the list of comments awaiting moderation' do
    render
    rendered.should have_link('comments', href: comments_path)
  end

  it 'has a link back to the administrator dashboard' do
    render
    rendered.should have_link('administrator dashboard', href: admin_dashboard_path)
  end
end
