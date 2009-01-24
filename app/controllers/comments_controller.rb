class CommentsController < ApplicationController
  before_filter :require_admin, :except => [ :create, :show ]
  before_filter :get_comment, :only => [ :edit, :update, :destroy ]
  cache_sweeper :comment_sweeper, :only => [ :create, :update, :destroy ]

  # Admin only.
  # The admin is allowed to see all unmoderated comments at once, for the purposes of moderation.
  def index
    @paginator  = Paginator.new params, Comment.count(:conditions => { :awaiting_moderation => true }), comments_url
    @comments   = Comment.find_recent :offset => @paginator.offset, :conditions => { :awaiting_moderation => true }
  end

  # Rather than showing a comment in isolation, always show it nested in the context of its parent resource
  def show
    if admin?
      @comment = Comment.find params[:id], :conditions => { :spam => false }
    elsif logged_in?
      @comment = Comment.find params[:id],
        :conditions => ['spam = FALSE AND awaiting_moderation = FALSE AND (public = TRUE OR user_id = ?)', current_user.id]
    else # anonymous user
      @comment = Comment.find params[:id], :conditions => { :public => true, :spam => false, :awaiting_moderation => false }
    end
    redirect_to nested_comment_url(@comment)
  end

  def create
    # not sure if this is the nicest way to do this
    # seems a necessary evil of nested polymorphic associations
    uri = request.request_uri
    raise if uri =~ /\?/
    components = uri.split '/'

    if components.length == 4
      # blog/:id/comments
      # wiki/:id/comments
      root, parent, parent_id, nested = components
      case parent
      when 'blog'
        parent_instance = Post.find_by_permalink!(parent_id)
        parent_url = post_url parent_instance
      when 'wiki'
        parent_instance = Article.find_by_title!(parent_id)
        parent_url = article_url parent_instance
      when 'issues'
        parent_instance = Issue.find(parent_id)
        parent_url = issue_url parent_instance
      else
        raise
      end
    elsif components.length == 6
      # forums/:id/topics/:id/comments
      root, grandparent, grandparent_id, parent, parent_id, nested = components
      raise unless grandparent == 'forums'
      raise unless parent == 'topics'
      grandparent_instance = Forum.find_with_param! grandparent_id
      parent_instance = Topic.first :conditions => { :forum_id => grandparent_instance.id, :id => parent_id }
      raise unless parent_instance
      parent_url = forum_topic_url grandparent_instance, parent_instance
    else
      raise
    end
    raise if root != ''
    raise if not parent_instance.accepts_comments

    # now create comment and try to add it
    @comment = parent_instance.comments.build params[:comment]
    @comment.user = current_user
    @comment.public = params[:comment][:public] if admin? && params[:comment] && params[:comment].key?(:public)
    @comment.awaiting_moderation = !(admin? or logged_in_and_verified?)
    if @comment.save
      if @comment.awaiting_moderation
        flash[:notice] = 'Your comment has been queued for moderation.'
      else
        flash[:notice] = 'Successfully added new comment.'
      end
      redirect_to parent_url
    else
      flash[:error] = 'Failed to add new comment.'
      render :action => 'new'
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
          redirect_to (@comment.awaiting_moderation ? comments_url : nested_comment_url(@comment))
        else
          flash[:error] = 'Update failed'
          render :action => 'edit'
        end
      }
      format.js {
        if params[:button] == 'spam'
          @comment.moderate_as_spam!
          render :update do |page|
            page.visual_effect :fade, "comment_#{@comment.id}"
          end
        elsif params[:button] == 'ham'
          @comment.moderate_as_ham!
          render :update do |page|
            page.visual_effect :highlight, "comment_#{@comment.id}", :duration => 1.5
            page.visual_effect :fade, "comment_#{@comment.id}_ham_form"
            page.visual_effect :fade, "comment_#{@comment.id}_spam_form"
          end
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
        redirect_to comments_url
      }
      format.js {
        render :update do |page|
          page.visual_effect :fade, "comment_#{@comment.id}"
        end
      }
    end
  end

private

  def get_comment
    if admin?
      @comment = Comment.find params[:id]
    elsif logged_in?
      @comment = Comment.find params[:id], :conditions => { :user_id => current_user.id, :spam => false }
    else
      # should never get here; and in fact, shouldn't even get to the previous case either
      # but leave it in for now, as may eventually allow users to edit their own comments
      raise "anonymous users can't manipulate comments"
    end
  end

end
