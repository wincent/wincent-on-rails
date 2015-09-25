class CommentsController < ApplicationController
  # Rather than showing a comment in isolation, always show it nested in the
  # context of its parent resource
  def show
    if admin?
      @comment = Comment.find params[:id]
    elsif logged_in?
      @comment = Comment.where(awaiting_moderation: false).
        where('public = ? OR user_id = ?', true, current_user_id)
        find(params[:id])
    else # anonymous user
      @comment = Comment.where(public: true, awaiting_moderation: false).
        find(params[:id])
    end
    redirect_to nested_comment_path(@comment)
  end

private

  # URL to the comment nested in the context of its parent (resources), including an anchor.
  # NOTE: this method is dog slow if called in an "N + 1 SELECT" situation
  def nested_comment_path comment
    # Article, Issue, Post, Snippet
    commentable = comment.commentable
    anchor      = "comment_#{comment.id}"
    polymorphic_path commentable, :anchor => anchor
  rescue NameError
    # Probably a deleted class, like Topic.
    raise ActiveRecord::RecordNotFound
  end
end
