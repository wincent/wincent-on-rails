class PostsController < ApplicationController
  before_filter :require_admin, :except => [ :index, :show ]
  before_filter :get_post, :only => [ :show, :edit, :update ]

  def index
    respond_to do |format|
      format.html {
        # BUG: we have another "n + 1" SELECT problem here
        # for each post we do a query to get its tags (involving a JOIN to the taggings table)
        # may be worth caching the tags in a field in the model? not sure
        # could do this automatically as part of acts_as_taggable
        @paginator  = Paginator.new(params, Post.count(:conditions => {:public => true}), blog_index_path)
        #@posts      = Post.find_recent(:offset => @paginator.offset)
        
        
        # this eliminates the tag-related queries, but there is a remaining "n + 1" problem
        # with the comment counts; each post causes a query like this one:
        #   SELECT count(*) AS count_all
        #   FROM `comments`
        #   WHERE (comments.commentable_id = 44 AND comments.commentable_type = 'Post' AND (spam = FALSE))
        # the incorporation of the spam condition makes the counter cache useless (and unused)
        @posts      = Post.find_recent(:include => :tags, :offset => @paginator.offset)
      }
      format.atom {
        @posts      = Post.find_recent
      }
    end
  end

  def new
    @post = Post.new(session[:new_post_params])
    session[:new_post_params] = nil
  end

  def create
    respond_to do |format|
      format.html {
        @post = Post.new(params[:post])
        if @post.save
          flash[:notice] = 'Successfully created new post.'
          redirect_to blog_path(@post)
        else
          flash[:error] = 'Failed to create new post.'
          render :action => 'new'
        end
      }

      # this is the AJAX preview
      format.js {
        @title    = params[:title]   || ''
        @excerpt  = params[:excerpt] || ''
        @body     = params[:body]    || ''
        render :partial => 'preview'
      }
    end
  end

  def show
    @comment = @post.comments.build if @post.accepts_comments?
  end

  def edit
    render
  end

  def update
    if @post.update_attributes(params[:post])
      flash[:notice] = 'Successfully updated'
      redirect_to blog_path(@post)
    else
      flash[:error] = 'Update failed'
      render :action => 'edit'
    end
  end

private

  def get_post
    @post = Post.find_by_permalink(params[:id]) || Post.find(params[:id])
  end

  def record_not_found
    if admin?
      flash[:notice] = 'Requested post not found: create it?'
      session[:new_post_params] = { :title => params[:id], :permalink => params[:id] }
      redirect_to new_blog_path
    else
      super blog_index_path
    end
  end
end
