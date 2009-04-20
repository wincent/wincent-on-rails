class Admin::TagsController < ApplicationController
  before_filter           :require_admin
  before_filter           :find_tag, :only => [:show, :update]
  acts_as_sortable        :by => [:name, :taggings_count], :default => :name
  uses_dynamic_javascript :only => :index

  def index
    @tags = Tag.find :all, sort_options
  end

  def show
    respond_to do |format|
      format.js { # AJAX updates
        render :json => @tag.to_json(:only => [:name])
      }
    end
  end

  def update
    respond_to do |format|
      format.js { # an AJAX update
        if @tag.update_attributes params[:tag]
          # don't use admin_tag_url here because we want to force the use of a
          # numeric id; url_for will keep us in admin namespace here
          redirect_to url_for(:controller => 'tags', :action => 'show',
            :id => @tag.id, :protocol => 'https')
        else
          render :text => '', :status => 422
        end
      }
    end
  end

protected

  def find_tag
    # unlike in the non-admin tags controller, find using numeric id
    # (for compatibility with the in-place-editing AJAX)
    @tag = Tag.find params[:id]
  end
end
