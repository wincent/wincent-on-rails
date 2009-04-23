class LinksController < ApplicationController
  before_filter     :require_admin, :except => :show
  before_filter     :find_link, :only => [:edit, :show, :update, :destroy]
  acts_as_sortable  :by => [:id, :uri, :permalink, :click_count]
  uses_dynamic_javascript :only => :index

  def index
    @links = Link.find :all, sort_options
  end

  def new
    render
  end

  def create
    @link = Link.new params[:link]
    respond_to do |format|
      if @link.save
        flash[:notice] = 'Successfully created new link.'
        format.html { redirect_to links_url } # don't redirect to actual link ("show" itself is just a redirect)
        #format.xml  { render :xml => @link, :status => :created, :location => @link }
      else
        flash[:error] = 'Failed to create new link.'
        format.html { render :action => 'new' }
        #format.xml  { render :xml => @link.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    respond_to do |format|
      format.html {
        # TODO: extract into Link#hit! method
        Link.increment_counter :click_count, @link.id
        redirect_to @link.uri, :status => 303 # "See other", GET request
      }
      format.js { # AJAX updates
        require_admin do
          # don't leak out any more information than necessary
          render :json => @link.to_json(:only => [:uri, :permalink])
        end
      }
    end
  end

  def edit
    render
  end

  def update
    respond_to do |format|
      format.js { # an AJAX update
        if @link.update_attributes params[:link]
          redirect_to link_url(@link, :format => :js)
        else
          render :text => 'Update failed', :status => 422
        end
      }
    end
  end

  def destroy

  end

private

  def find_link
    @link = Link.find_by_permalink(params[:id]) || Link.find(params[:id])
  end

  def record_not_found
    super(admin? ? links_url : nil)
  end

end
