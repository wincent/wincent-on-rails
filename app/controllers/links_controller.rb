class LinksController < ApplicationController
  before_filter    :require_admin, except: :show
  before_filter    :find_link, only: %i[edit show update destroy]
  acts_as_sortable by: %i[id uri permalink click_count]

  def index
    @links = Link.order sort_options
  end

  def new
    @link = Link.new
  end

  def create
    @link = Link.new params[:link]
    respond_to do |format|
      if @link.save
        # don't redirect to actual link ("show" itself is just a redirect)
        flash[:notice] = 'Successfully created new link'
        format.html { redirect_to links_path }
      else
        flash[:error] = 'Failed to create new link'
        format.html { render action: 'new' }
      end
    end
  end

  def show
    respond_to do |format|
      format.html {
        # TODO: extract into Link#hit! method
        Link.increment_counter :click_count, @link.id
        redirect_to @link.redirection_url, status: 303 # "See other", GET request
      }
      format.js { # AJAX updates
        # don't leak out any more information than necessary
        render json: @link.to_json(only: %i[uri permalink])
      }
    end
  end

  def edit
    render
  end

  def update
    respond_to do |format|
      format.html do
        if @link.update_attributes params[:link]
          flash[:notice] = 'Successfully updated'
          redirect_to links_path # can't redirect to #show
        else
          flash[:error] = 'Update failed'
          render action: :edit
        end
      end

      format.js do # an AJAX update
        if @link.update_attributes params[:link]
          render json: {}
        else
          render text:   "Update failed: #{@link.flashable_error_string}",
                 status: 422
        end
      end
    end
  end

  def destroy
    # TODO: mark links as deleted_at rather than really destroying them
    @link.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = 'Link destroyed'
        redirect_to links_path
      }
      format.js
    end
  end

private

  def find_link
    @link = Link.find_by_permalink(params[:id]) || Link.find(params[:id])
  end

  def record_not_found
    super(admin? ? links_path : nil)
  end
end
