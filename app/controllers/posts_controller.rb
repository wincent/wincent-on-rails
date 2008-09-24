class PostsController < ApplicationController
  before_filter :require_admin, :except => [ :index, :show ]
  before_filter :get_post,      :except => [ :index, :new, :create ]
  caches_page   :index,         :if => Proc.new { |c| c.send(:is_atom?) }
  cache_sweeper :post_sweeper,  :only => [ :create, :update, :destroy ]

  def index
    respond_to do |format|
      format.html {
        # NOTE: don't be tempted to page cache this action/format (it shows relative timestamps)
        @paginator  = Paginator.new params, Post.count(:conditions => { :public => true }), posts_path

        # BUG: with the comment counts; each post causes a query like this one:
        #   SELECT count(*) AS count_all
        #   FROM `comments`
        #   WHERE (comments.commentable_id = 44 AND comments.commentable_type = 'Post' AND (spam = FALSE))
        # the incorporation of the spam condition makes the counter cache useless (and unused)
        @posts      = Post.find_recent :include => :tags, :offset => @paginator.offset
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
          redirect_to post_path(@post)
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
    redirect_to posts_path
  end

  def show
    # TODO: would be nice to have prev/next links here as well
    # simplest way without doing more db queries might be to just add new actions: next and prev, which then redirect
    # the drawback there is that there is no pre-check to see when you're on the first or last page
    # and the links would be "dumb", ie "next" and "prev" rather than links featuring titles
    @comment = @post.comments.build if @post.accepts_comments?
  end

  def edit
    render
  end

  def update
    if @post.update_attributes params[:post]
      flash[:notice] = 'Successfully updated'
      redirect_to post_path(@post)
    else
      flash[:error] = 'Update failed'
      render :action => 'edit'
    end
  end

private

  def get_post
    if admin?
      @post = Post.find_by_permalink(params[:id]) || (raise ActiveRecord::RecordNotFound)
    else
      @post = Post.find_by_permalink_and_public(params[:id], true) || (raise ActiveRecord::RecordNotFound)
    end
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
