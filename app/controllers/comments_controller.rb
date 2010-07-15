class CommentsController < ApplicationController
  before_filter :require_admin, :except => [ :create, :new, :show ]
  before_filter :get_comment, :only => [ :edit, :update, :destroy ]
  before_filter :get_parent, :only => [:create, :new]
  cache_sweeper :comment_sweeper, :only => [ :create, :update, :destroy ]

  # Admin only.
  # The admin is allowed to see all unmoderated comments at once, for the purposes of moderation.
  def index
    # abuse of ActiveRelation behavior here: "recent" has "limit(10)" on it,
    # but when we append "count" we get the count of all available rows, not
    # what we would get if we actually executed a SELECT query
    # see: https://rails.lighthouseapp.com/projects/8994/tickets/5060
    comments    = Comment.recent.where(:awaiting_moderation => true)
    @paginator  = Paginator.new params, comments.count, comments_path
    @comments   = comments.offset(@paginator.offset)
  end

  def new
    @comment = @parent.comments.build
    if request.xhr?
      render :partial => 'form'
    else
      render
    end
  end

  # Rather than showing a comment in isolation, always show it nested in the
  # context of its parent resource
  def show
    if admin?
      @comment = Comment.find params[:id]
    elsif logged_in?
      t = Comment.arel_table
      @comment = Comment.where(:awaiting_moderation => false).
        where(t[:public].eq(true).or(t[:user_id].eq(current_user.id))).
        find(params[:id])
    else # anonymous user
      @comment = Comment.where(:public => true, :awaiting_moderation => false).
        find(params[:id])
    end
    redirect_to nested_comment_path(@comment)
  end

  def create
    @comment = @parent.comments.build params[:comment]
    @comment.user = current_user
    @comment.public = params[:comment][:public] if admin? && params[:comment] && params[:comment].key?(:public)
    @comment.awaiting_moderation = !(admin? or logged_in_and_verified?)
    if @comment.save
      if @comment.awaiting_moderation
        flash[:notice] = 'Your comment has been queued for moderation'
      else
        flash[:notice] = 'Successfully added new comment'
      end
      redirect_to polymorphic_path([@grandparent, @parent].compact)
    else
      flash[:error] = 'Failed to add new comment'
      render 'new'
    end
  end

  # Admin only for now.
  def edit
    render
  end

  # Admin only for now.
  def update
    respond_to do |format|
      format.html {
        @comment.public = params[:comment][:public] if params[:comment] && params[:comment].key?(:public)
        if @comment.update_attributes params[:comment]
          flash[:notice] = 'Successfully updated'
          redirect_to (@comment.awaiting_moderation ? comments_path : nested_comment_path(@comment))
        else
          flash[:error] = 'Update failed'
          render :action => 'edit'
        end
      }
      format.js {
        if params[:button] == 'ham'
          @comment.moderate_as_ham!
          render :json => {}.to_json
        else
          raise 'unrecognized AJAX action'
        end
      }
    end
  end

  def destroy
    # TODO: mark comments as deleted_at rather than really destroying them
    @comment.destroy
    respond_to do |format|
      format.html {
        # TODO: add flash here, but first check if there are actually any HTML links to this action and format
        redirect_to comments_path
      }
      format.js {
        render :json => {}.to_json
      }
    end
  end

private

  def get_parent
    if parent = params[:article_id]
      @parent = Article.find_with_param! parent, current_user
    elsif parent = params[:issue_id]
      @parent = Issue.find parent
    elsif parent = params[:post_id]
      @parent = Post.find_by_permalink! parent
    elsif parent = params[:tweet_id]
      @parent = Tweet.find parent
    elsif parent = params[:topic_id] and grandparent = params[:forum_id]
      @grandparent = Forum.find_with_param! grandparent
      @parent = @grandparent.topics.where(:id => parent).first
    end
    raise ActiveRecord::RecordNotFound.new('no parent instance') unless @parent

    if !@parent.accepts_comments
      raise ActionController::ForbiddenError.new \
        'parent does not accept comments'
    end
  end

  def get_comment
    if admin?
      @comment = Comment.find params[:id]
    elsif logged_in?
      @comment = Comment.where(:user_id => current_user.id).find(params[:id])
    else
      # should never get here; and in fact, shouldn't even get to the previous case either
      # but leave it in for now, as may eventually allow users to edit their own comments
      raise "anonymous users can't manipulate comments"
    end
  end
end
