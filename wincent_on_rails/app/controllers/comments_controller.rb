class CommentsController < ApplicationController
  before_filter :require_user, :only => [ :index ]

  def index
    if admin?         # admins can see all comments
      @comments = Comment.find(:all)
    else              # all other in users can only see their own
      @comments = Comment.find_by_user_id(current_user.id)
    end
  end

  def show
    render
  end

  def create
    # not sure if this is the nicest way to do this
    # seems a necessary evil of nested polymorphic associations
    uri = request.request_uri
    raise if uri =~ /\?/
    components = uri.split '/'
    raise if components.length != 4
    root, parent, parent_id, nested = components
    raise if root != ''
    case parent
    when 'blog'
      parent_instance = Post.find_by_permalink(parent_id) || Post.find(parent_id)
    when 'wiki'
      parent_instance = Article.find_by_title(parent.id) || Article.find(parent_id)
    else
      raise
    end

    # now create comment and try to add it
    @comment = parent_instance.comments.build(params[:comment])
    @comment.user = current_user
    @comment.awaiting_moderation = false if admin? # consider turning off moderation: can turn it on if needed
    if @comment.save
      # again this is quite ugly due to the polymorphic association
      flash[:notice] = 'Successfully added new comment.'
      redirect_to (send "#{parent}_path", parent_instance)
    else
      flash[:error] = 'Failed to add new comment.'
      render :action => 'new'
    end
  end

  def update
    respond_to do |format|
      format.html { raise "not yet implemented" }
      format.js {
        raise unless admin? # most likely an attack
        comment = Comment.find(params[:id])
        comment.awaiting_moderation = false
        if params[:button] == 'spam'
          comment.spam = true  # protected attributes, so can't use mass assignment
          comment.save
          render :update do |page|
            page.visual_effect :fade, "comment_#{comment.id}"
          end
        elsif params[:button] == 'ham'
          comment.save
          render :update do |page|
            page.visual_effect :highlight, "comment_#{comment.id}", :duration => 1.5
            page.visual_effect :fade, "comment_#{comment.id}_ham_form"
            page.visual_effect :fade, "comment_#{comment.id}_spam_form"
          end
        else
          # error
          raise # should do somethign else
        end
      }
    end
  end
end
