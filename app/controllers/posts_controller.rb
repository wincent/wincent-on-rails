class PostsController < ApplicationController
  before_filter :require_admin, :except => [ :index, :show ]
  before_filter :get_post,      :except => [ :index, :new, :create ]
  caches_page   :index, :show,  :if => Proc.new { |c| c.request.format.atom? }
  cache_sweeper :post_sweeper,  :only => [ :create, :update, :destroy ]
  uses_stylesheet_links

  def index
    respond_to do |format|
      format.html {
        @paginator  = RestfulPaginator.new params,
          Post.count(:conditions => { :public => true }), posts_path
        @posts      = Post.find_recent :include => :tags, :offset => @paginator.offset
        @tweets     = Tweet.find_recent if !fragment_exist?(:tweets_sidebar)
      }
      format.atom { @posts = Post.find_recent }
    end
  end

  def new
    @post = Post.new session[:new_post_params]
    session[:new_post_params] = nil
  end

  def create
    if request.xhr? # live preview
      @post = Post.new :title => params[:title], :excerpt => params[:excerpt], :body => params[:body]
      render :partial => 'preview'
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
      format.atom
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
      render :action => 'edit'
    end
  end

private

  def get_post
    if admin?
      @post = Post.find_by_permalink!(params[:id])
    else
      @post = Post.find_by_permalink_and_public!(params[:id], true)
    end
  rescue ActiveRecord::RecordNotFound => e
    # given permalink "foo" a request for "foo.atom" or "foo.js" will land here
    if params[:id] =~ /(.+)\.(atom|js)\Z/
      request.format = $~[2].to_sym
      @post = Post.find_by_permalink_and_public $~[1], true
    end
    raise e unless @post
  end

  def record_not_found
    if admin?
      flash[:notice] = 'Requested post not found: create it?'
      session[:new_post_params] = { :title => params[:id], :permalink => params[:id] }
      redirect_to new_post_path
    else
      super posts_path
    end
  end
end
