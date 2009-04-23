class Admin::PostsController < ApplicationController
  before_filter           :require_admin
  before_filter           :find_post, :only => [:show, :update]
  uses_dynamic_javascript :only => :index

  # TODO: really need a published_at field, I think
  # TODO: add "public", "accepts comments" and "comments_count" columns here
  acts_as_sortable  :by => [:title, :permalink, :created_at], :default => :created_at

  def index
    # TODO: combine sortability with pagination?
    @posts = Post.find(:all, sort_options)
  end

  def show
    respond_to do |format|
      format.js { # AJAX updates
        render :json => @post.to_json(:only => [:permalink, :title])
      }
    end
  end

  def update
    respond_to do |format|
      format.js { # an AJAX update
        if @post.update_attributes params[:post]
          # don't use admin_post_url here because we want to force the use of a
          # numeric id; url_for will keep us in admin namespace here
          redirect_to url_for(:controller => 'posts', :action => 'show',
            :id => @post.id, :protocol => 'https')
        else
          error = "Update failed: #{@post.flashable_error_string}"
          render :text => error, :status => 422
        end
      }
    end
  end

protected

  def find_post
    # unlike in the non-admin posts controller, find using numeric id
    # (for compatibility with the in-place-editing AJAX)
    @post = Post.find params[:id]
  end
end
