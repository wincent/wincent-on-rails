class LinksController < ApplicationController
  before_filter     :require_admin, :except => :show
  before_filter     :find_link, :only => [:edit, :show, :update, :destroy]
  in_place_edit_for :link, :uri
  in_place_edit_for :link, :permalink
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
    # TODO: extract into Link#hit! method
    Link.increment_counter :click_count, @link.id
    redirect_to @link.uri, :status => 303 # "See other", GET request
  end

  def edit
    render
  end

  def update

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
