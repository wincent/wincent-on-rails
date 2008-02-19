class LinksController < ApplicationController
  before_filter     :require_admin, :except => :show
  before_filter     :get_link,      :only => [:edit, :update, :destroy]
  in_place_edit_for :link, :uri
  in_place_edit_for :link, :permalink
  acts_as_sortable  :by => [:id, :uri, :permalink, :click_count]

  def index
    @links = Link.find(:all, sort_options)
  end

  def new
    render
  end

  def create
    @link = Link.new(params[:link])
    respond_to do |format|
      if @link.save
        flash[:notice] = 'Successfully created new link.'
        format.html { redirect_to links_path } # don't redirect to actual link ("show" itself is just a redirect)
        #format.xml  { render :xml => @link, :status => :created, :location => @link }
      else
        flash[:error] = 'Failed to create new link.'
        format.html { render :action => 'new' }
        #format.xml  { render :xml => @link.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
    Link.transaction do
      # lock here to avoid races while incrementing
      get_link :lock => true
      @link.increment! :click_count
    end
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

  def get_link options = {}
    @link = Link.find_by_permalink(params[:id], options) || Link.find(params[:id], options)
  end

  def record_not_found
    super(admin? ? links_path : nil)
  end

end
