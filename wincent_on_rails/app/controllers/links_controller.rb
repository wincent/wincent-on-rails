class LinksController < ApplicationController
  before_filter     :require_admin, :except => :show
  before_filter     :get_link,      :except => [:index, :show]
  in_place_edit_for :link, :uri
  in_place_edit_for :link, :permalink
  acts_as_sortable  :by => [:uri, :permalink, :click_count]

  def index
    @links = Link.find(:all, sort_options)
  end

  def new
    #render
  end

  def create

  end

  def show
    Link.transaction do
      # lock here to avoid races while incrementing
      get_link :lock => true
      @link.increment! :click_count
    end
    redirect_to @link.uri
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
