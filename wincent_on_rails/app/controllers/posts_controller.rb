class PostsController < ApplicationController
  before_filter :require_admin, :except => [ :index, :show ]
  before_filter :get_post, :only => [ :show, :edit, :update ]

  def index
    respond_to do |format|
      format.html {
        @paginator  = Paginator.new(params, Post.count(:conditions => {:public => true}), blog_index_path)
        @posts      = Post.find_recent(:offset => @paginator.offset)
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
    @comment = @post.comments.build if @post.accepts_comments? && logged_in?
    render
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
