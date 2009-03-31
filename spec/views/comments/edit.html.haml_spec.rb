require File.dirname(__FILE__) + '/../../spec_helper'

describe '/comments/edit' do
  include CommentsHelper

  before do
    assigns[:comment] = @comment = create_comment
  end

  def do_render
    render '/comments/edit'
  end

  it 'should have a link back to the commentable model' do
    template.should_receive(:link_to_commentable).with(@comment.commentable)
    do_render
  end

  it 'should have a div for the comment' do
    do_render
    response.should have_tag("\#comment_#{@comment.id}")
  end

  it 'should have a show button' do
    do_render
    response.should have_tag('.links') do
      with_tag 'a[href=?]', comment_url(@comment)
    end
  end

  it 'should have a destroy button' do
    template.should_receive(:button_to_destroy_comment).with(@comment)
    do_render
  end

  it 'should have a ham button' do
    template.should_receive(:button_to_moderate_comment_as_ham).with(@comment)
    do_render
  end

  it 'should have a link back to the list of comments awaiting moderation' do
    do_render
    response.should have_tag('.links') do
      with_tag 'a[href=?]', comments_url
    end
  end

  it 'should have a link back to the administrator dashboard' do
    do_render
    response.should have_tag('.links') do
      with_tag 'a[href=?]', admin_dashboard_url
    end
  end
end
