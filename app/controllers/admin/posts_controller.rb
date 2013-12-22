class Admin::PostsController < Admin::ApplicationController
  before_filter           :find_post, :only => [:show, :update]

  # TODO: really need a published_at field, I think
  # TODO: add "public", "accepts comments" and "comments_count" columns here
  acts_as_sortable  :by => [:title, :permalink, :created_at], :default => :created_at

  def index
    # TODO: combine sortability with pagination?
    @posts = Post.order sort_options
  end

  def show
    respond_to do |format|
      format.js do
        render json: @post.to_json(only: %i[permalink title])
      end
    end
  end

  def update
    respond_to do |format|
      format.js do
        if @post.update_attributes(params[:post])
          # don't use admin_post_path here because we want to force the use of a
          # numeric id; url_for will keep us in admin namespace here
          redirect_to url_for(controller: 'posts',
                              action: 'show',
                              id: @post.id)
        else
          render text:   "Update failed: #{@post.flashable_error_string}",
                 status: 422
        end
      end
    end
  end

protected

  def find_post
    # unlike in the non-admin posts controller, find using numeric id
    # (for compatibility with the in-place-editing AJAX)
    @post = Post.find params[:id]
  end
end
