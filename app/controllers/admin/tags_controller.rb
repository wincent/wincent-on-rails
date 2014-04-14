class Admin::TagsController < Admin::ApplicationController
  before_filter           :find_tag, :only => [:show, :update]
  acts_as_sortable        :by => [:name, :taggings_count], :default => :name

  def index
    @tags = Tag.order sort_options
  end

  def show
    respond_to do |format|
      format.js { # Ajax updates
        render :json => @tag.to_json(:only => [:name])
      }
    end
  end

  def update
    respond_to do |format|
      format.js { # an Ajax update
        if @tag.update_attributes params[:tag]
          # don't use admin_tag_path here because we want to force the use of a
          # numeric id; url_for will keep us in admin namespace here
          redirect_to url_for(:controller => 'tags', :action => 'show',
            :id => @tag.id)
        else
          error = "Update failed: #{@tag.flashable_error_string}"
          render :text => error, :status => 422
        end
      }
    end
  end

protected

  def find_tag
    # unlike in the non-admin tags controller, find using numeric id
    # (for compatibility with the in-place-editing Ajax)
    @tag = Tag.find params[:id]
  end
end
