class CommentsController < ApplicationController
  before_filter :require_admin, :except => [ :create, :new, :show ]
  before_filter :get_comment, :only => [ :edit, :update, :destroy ]
  before_filter :get_parent, :only => [:create, :new]
  cache_sweeper :comment_sweeper, :only => [ :create, :update, :destroy ]

  # Admin only.
  # The admin is allowed to see all unmoderated comments at once, for the purposes of moderation.
  def index
    @paginator  = Paginator.new params, Comment.count(:conditions => { :awaiting_moderation => true }), comments_path
    @comments   = Comment.find_recent :offset => @paginator.offset, :conditions => { :awaiting_moderation => true }
  end

  def new
    @comment = @parent_instance.comments.build
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
      @comment = Comment.find params[:id],
        :conditions => ['awaiting_moderation = FALSE AND (public = TRUE OR user_id = ?)', current_user.id]
    else # anonymous user
      @comment = Comment.find params[:id], :conditions => { :public => true, :awaiting_moderation => false }
    end
    redirect_to nested_comment_path(@comment)
  end

  def create
    @comment = @parent_instance.comments.build params[:comment]
    @comment.user = current_user
    @comment.public = params[:comment][:public] if admin? && params[:comment] && params[:comment].key?(:public)
    @comment.awaiting_moderation = !(admin? or logged_in_and_verified?)
    if @comment.save
      if @comment.awaiting_moderation
        flash[:notice] = 'Your comment has been queued for moderation.'
      else
        flash[:notice] = 'Successfully added new comment.'
      end
    else
      flash[:error] = 'Failed to add new comment.'
    end
    redirect_to @parent_path
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
    # ugly but a necessary evil of multi-level, nested polymorphic associations
    uri = request.request_uri
    raise if uri =~ /\?/
    components = uri.split '/'

    if (4..5).include? components.length
      # blog/:id/comments,    blog/:id/comments/new
      # twitter/:id/comments, twitter/:id/comments/new
      # issues/:id/comments,  issues/:id/comments/new
      # wiki/:id/comments,    wiki/:id/comments/new
      root, parent, parent_id, nested, action = components
      raise 'unexpected action' if action && action != 'new'
      case parent
      when 'blog'
        @parent_instance = Post.find_by_permalink!(parent_id)
      when 'issues'
        @parent_instance = Issue.find(parent_id)
      when 'twitter'
        @parent_instance = Tweet.find(parent_id)
      when 'wiki'
        @parent_instance = Article.find_with_param!(parent_id)
      else
        raise 'unexpected parent'
      end
      @parent_path = polymorphic_path @parent_instance
    elsif (6..7).include? components.length
      # forums/:id/topics/:id/comments, forums/:id/topics/.id/comments/new
      root, grandparent, grandparent_id, parent, parent_id, nested, action = components
      raise 'unexpected action' if action && action != 'new'
      raise 'unexpected grandparent' unless grandparent == 'forums'
      raise 'unexpected parent' unless parent == 'topics'
      grandparent_instance = Forum.find_with_param! grandparent_id
      @parent_instance = Topic.first :conditions => { :forum_id => grandparent_instance.id, :id => parent_id }
      raise 'no parent instance' unless @parent_instance
      @parent_path = forum_topic_path grandparent_instance, @parent_instance
    else
      raise 'wrong number of components'
    end
    raise 'non-empty root' if root != ''
    raise 'parent does not accept comments' if not @parent_instance.accepts_comments
  end

  def get_comment
    if admin?
      @comment = Comment.find params[:id]
    elsif logged_in?
      @comment = Comment.find params[:id], :conditions => { :user_id => current_user.id }
    else
      # should never get here; and in fact, shouldn't even get to the previous case either
      # but leave it in for now, as may eventually allow users to edit their own comments
      raise "anonymous users can't manipulate comments"
    end
  end
end
