class TweetsController < ApplicationController
  before_filter :require_admin, :except => [ :index, :show ]
  before_filter :get_tweet,     :only => [ :edit, :show, :update, :destroy ]
  caches_page   :index, :show   # Atom and HTML
  cache_sweeper :tweet_sweeper, :only => [ :create, :update, :destroy ]
  uses_dynamic_javascript :only => [:edit, :new]

  def index
    respond_to do |format|
      format.html {
        @paginator  = RestfulPaginator.new params, Tweet.count, tweets_url, 20
        @tweets     = Tweet.find_recent @paginator
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
          redirect_to tweet_url(@tweet)
        else
          flash[:error] = 'Failed to create new tweet'
          render :action => 'new'
        end
      }

      # AJAX preview
      format.js {
        @tweet  = Tweet.new :body => params[:body]
        # must specify full name here because 'preview' alone
        # makes Rails look for 'preview.js.haml'
        render :partial => 'preview.html.haml'
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
    redirect_to tweets_url
  end

private

  def get_tweet
    @tweet = Tweet.find params[:id]
  end

  def record_not_found
    super tweets_url
  end
end
