class Admin::ForumsController < ApplicationController
  before_filter           :require_admin
  before_filter           :find_forum, :only => [:show, :update]
  uses_dynamic_javascript :only => :index

  def index
    @forums = Forum.find :all
  end

  def show
    respond_to do |format|
      format.js { # AJAX updates
        render :json => @forum.to_json(:only => [:description, :name,
          :position])
      }
    end
  end

  def update
    respond_to do |format|
      format.js { # an AJAX update
        @forum.position = params[:forum][:position] if
          params[:forum].key?(:position)
        if @forum.update_attributes params[:forum]
          # don't use admin_forum_path here because we want to force the use of a
          # numeric id; url_for will keep us in admin namespace here
          redirect_to url_for(:controller => 'forums', :action => 'show',
            :id => @forum.id, :protocol => 'https')
        else
          error = "Update failed: #{@forum.flashable_error_string}"
          render :text => error, :status => 422
        end
      }
    end
  end

protected

  def find_forum
    # unlike in the non-admin forums controller, find using numeric id
    # (for compatibility with the in-place-editing AJAX)
    @forum = Forum.find params[:id]
  end
end
