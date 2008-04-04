class CommentsController < ApplicationController
  before_filter :require_admin, :except => [ :create, :show ]
  before_filter :get_comment, :only => [ :edit, :update, :destroy ]
  cache_sweeper :comment_sweeper, :only => [ :create, :update, :destroy ]

  # Admin only.
  # The admin is allowed to see all unmoderated comments at once, for the purposes of moderation.
  def index
    @paginator  = Paginator.new params, Comment.count(:conditions => { :awaiting_moderation => true }), comments_path
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
    redirect_to url_for_comment(@comment)
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
        parent_instance = Post.find_by_permalink(parent_id) || (raise ActiveRecord::RecordNotFound)
        parent_path = blog_path parent_instance
      when 'wiki'
        parent_instance = Article.find_by_title(parent.id) || (raise ActiveRecord::RecordNotFound)
        parent_path = wiki_path parent_instance
      else
        raise
      end
    elsif components.length == 6
      # forums/:id/topics/:id/comments
      root, grandparent, grandparent_id, parent, parent_id, nested = components
      raise unless grandparent == 'forums'
      raise unless parent == 'topics'
      grandparent_instance = Forum.find_with_param! grandparent_id
      parent_instance = Topic.find :first, :conditions => { :forum_id => grandparent_instance.id, :id => parent_id }
      raise unless parent_instance
      parent_path = forum_topic_path grandparent_instance, parent_instance
    else
      raise
    end
    raise if root != ''
    raise if not parent_instance.accepts_comments

    # now create comment and try to add it
    @comment = parent_instance.comments.build params[:comment]
    @comment.user = current_user
    @comment.awaiting_moderation = (!admin? or !logged_in_and_verified?)
    if @comment.save
      if @comment.awaiting_moderation
        flash[:notice] = 'Your comment has been queued for moderation.'
      else
        flash[:notice] = 'Successfully added new comment.'
      end
      redirect_to parent_path
    else
      flash[:error] = 'Failed to add new comment.'
      render :action => 'new'
    end
  end

  def edit
    render
  end

  def update
    respond_to do |format|
      format.html {
        raise 'not yet implemented'
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
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to comments_path }
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
      raise "anonymous users can't manipulate comments"
    end
  end

end
