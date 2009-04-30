class TweetsController < ApplicationController
  before_filter :require_admin, :except => [ :index, :show ]
  before_filter :get_tweet,     :only => [ :edit, :show, :update, :destroy ]
  caches_page   :index, :show   # Atom and HTML
  cache_sweeper :tweet_sweeper, :only => [ :create, :update, :destroy ]
  uses_dynamic_javascript :only => [:edit, :new]

  def index
    respond_to do |format|
      format.html {
        @paginator  = RestfulPaginator.new params, Tweet.count, tweets_path, 20
        @tweets     = Tweet.find_recent :offset => @paginator.offset
      }
      format.atom {
        @tweets     = Tweet.find_recent
      }
    end
  end

  # Admin only.
  def new
    @tweet = Tweet.new
  end

  # Admin only.
  def create
    respond_to do |format|
      format.html {
        @tweet = Tweet.new params[:tweet]
        if @tweet.save
          flash[:notice] = 'Successfully created new tweet'
          redirect_to tweet_path(@tweet)
        else
          flash[:error] = 'Failed to create new tweet'
          render :action => 'new'
        end
      }

      # AJAX preview
      format.js {
        @tweet  = Tweet.new :body => params[:body]
        render :partial => 'preview.html.haml' # explicit extension required
      }
    end
  end

  def show
    render
  end

  # Admin only.
  def edit
    render
  end

  # Admin only.
  def update
    if @tweet.update_attributes params[:tweet]
      flash[:notice] = 'Successfully updated'
      render :action => :show
    else
      flash[:error] = 'Update failed'
      render :action => :edit
    end
  end

  # Admin only.
  def destroy
    # TODO: replace this with a delete-with-optional-undo model
    @tweet.destroy
    redirect_to tweets_path
  end

private

  def get_tweet
    @tweet = Tweet.find params[:id]
  end

  def record_not_found
    super tweets_path
  end
end
