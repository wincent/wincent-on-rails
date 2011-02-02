class SnippetsController < ApplicationController
  before_filter :require_admin, :except => [ :index, :show ]
  before_filter :get_published_snippet, :only => :show
  before_filter :get_snippet, :only => [ :edit, :update, :destroy ]
  caches_page   :index, :show # Atom and HTML
  cache_sweeper :snippet_sweeper, :only => [ :create, :update, :destroy ]
  uses_stylesheet_links

  def index
    respond_to do |format|
      format.html {
        @paginator = RestfulPaginator.new params, Snippet.published.count,
          snippets_path, 10
        @snippets = Snippet.recent.offset @paginator.offset
      }
      format.atom {
        @snippets = Snippet.recent
      }
    end
  end

  # Admin only.
  def new
    @snippet = Snippet.new
  end

  # Admin only.
  def create
    if request.xhr? # live preview
      @snippet = Snippet.new :body => params[:body],
        :description => params[:description],
        :markup_type => params[:markup_type]
      render :partial => 'preview'
    else # normal request
      @snippet = Snippet.new params[:snippet]
      if @snippet.save
        flash[:notice] = 'Successfully created new snippet'
        redirect_to @snippet
      else
        flash[:error] = 'Failed to create new snippet'
        render :action => 'new'
      end
    end
  end

  def show
    @comments = @snippet.comments.published
    respond_to do |format|
      format.html {
        @comment = @snippet.comments.build if @snippet.accepts_comments?
      }
      format.atom
      format.text { render :text => @snippet.body }
    end
  end

  # Admin only.
  def edit
    render
  end

  # Admin only.
  def update
    if @snippet.update_attributes params[:snippet]
      flash[:notice] = 'Successfully updated'
      redirect_to @snippet
    else
      flash[:error] = 'Update failed'
      render :action => :edit
    end
  end

  # Admin only.
  def destroy
    @snippet.destroy
    flash[:notice] = 'Successfully destroyed'
    redirect_to snippets_path
  end

private

  def get_snippet
    @snippet = Snippet.find params[:id]
  end

  # TODO: due to page caching, we can't afford to let admins see private
  # snippets, so will have to add an admin namespace for listing and showing
  # can always redirect there from here for admins
  def get_published_snippet
    @snippet = Snippet.published.find params[:id]
  end

  def record_not_found
    super snippets_path
  end
end
