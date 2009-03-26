class PostsController < ApplicationController
  before_filter :require_admin, :except => [ :index, :show ]
  before_filter :get_post,      :except => [ :index, :new, :create ]
  caches_page   :index, :show,  :if => Proc.new { |c| c.send(:is_atom?) }
  cache_sweeper :post_sweeper,  :only => [ :create, :update, :destroy ]

  def index
    respond_to do |format|
      format.html {
        @paginator  = Paginator.new params, Post.count(:conditions => { :public => true }), posts_url
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
    respond_to do |format|
      format.html {
        @post = Post.new params[:post]
        if @post.save
          flash[:notice] = 'Successfully created new post.'
          redirect_to post_url(@post)
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

  def destroy
    @post.destroy
    flash[:notice] = "Destroyed post: #{@post.title}"
    redirect_to posts_url
  end

  def show
    # TODO: would be nice to have prev/next links here as well
    # simplest way without doing more db queries might be to just add new actions: next and prev, which then redirect
    # the drawback there is that there is no pre-check to see when you're on the first or last page
    # and the links would be "dumb", ie "next" and "prev" rather than links featuring titles
    respond_to do |format|
      format.html { @comment = @post.comments.build if @post.accepts_comments? }
      format.atom
    end
  end

  def edit
    render
  end

  def update
    if @post.update_attributes params[:post]
      flash[:notice] = 'Successfully updated'
      redirect_to post_url(@post)
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
    # given permalink "foo" a request for "foo.atom" will most likely wind up here
    if params[:id] =~ /(.+)\.atom\Z/
      params[:format] = 'atom'
      @post = Post.find_by_permalink_and_public($~[1], true)
    end
    raise e unless @post
  end

  def record_not_found
    if admin?
      flash[:notice] = 'Requested post not found: create it?'
      session[:new_post_params] = { :title => params[:id], :permalink => params[:id] }
      redirect_to new_post_url
    else
      super posts_url
    end
  end
end
