# We used to have a dedicated "Tweet" model; all those old "tweets" have been
# migrated to Snippets, and this controller now just redirects to twitter.com.
class TweetsController < ApplicationController
  def index
    redirect_to APP_CONFIG['twitter_url'], status: :moved_permanently
  end
  alias show index
end
