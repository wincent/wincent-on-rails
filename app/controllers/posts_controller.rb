class PostsController < ApplicationController
  before_filter :require_admin, except: %i[index show]
  before_filter :get_post,      except: %i[index new create]

  def index
    respond_to do |format|
      format.html {
        @paginator = RestfulPaginator.new(params, Post.published.count, posts_path)
        @posts     = Post.recent.includes(:tags).offset(@paginator.offset).page
      }
    end
  end

  def new
    @post = Post.new session[:new_post_params]
    session[:new_post_params] = nil
  end

  def create
    if request.xhr? # live preview
      @post = Post.new(title:   params[:title],
                       excerpt: params[:excerpt],
                       body:    params[:body])
      render partial: 'preview'
    else # normal request
      @post = Post.new params[:post]
      if @post.save
        flash[:notice] = 'Successfully created new post'
        redirect_to @post
      else
        flash[:error] = 'Failed to create new post'
        render :action => 'new'
      end
    end
  end

  def destroy
    @post.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = 'Deleted post'
        redirect_to admin_posts_path
      }
      format.js
    end
  end

  def show
    # TODO: would be nice to have prev/next links here as well
    # see issues#show (find_prev_next before filter) for implementation ideas
    @comments = @post.comments.published
    respond_to do |format|
      format.html { @comment = @post.comments.new if @post.accepts_comments? }
    end
  end

  def edit
    render
  end

  def update
    if @post.update_attributes params[:post]
      flash[:notice] = 'Successfully updated'
      redirect_to @post
    else
      flash[:error] = 'Update failed'
      render action: 'edit'
    end
  end

private

  def get_post
    @post = if admin?
      Post.find_by_permalink(params[:id]) || Post.find(params[:id])
    else
      Post.published.find_by_permalink(params[:id]) || Post.published.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    # given permalink "foo" a request for "foo.js" will land here
    if params[:id] =~ /(.+)\.(js)\z/
      request.format = $~[2].to_sym
      @post = Post.published.find_by_permalink($~[1]) || Post.published.find($~[1])
    end
    raise unless @post
  end

  def record_not_found
    if admin?
      flash[:notice] = 'Requested post not found: create it?'
      session[:new_post_params] = { title: params[:id], permalink: params[:id] }
      redirect_to new_post_path
    else
      super posts_path
    end
  end
end
