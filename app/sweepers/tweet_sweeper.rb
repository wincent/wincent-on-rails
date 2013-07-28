class TweetSweeper < ActionController::Caching::Sweeper
  observe Tweet

  extend  Sweeping
  include Sweeping

  # on-demand cache expiration from Rake (`rake cache:clear`), RSpec etc
  def self.expire_all
    safe_expire tweets_path, :recurse => true # /twitter/**/*
    safe_expire tweets_path('.atom')          # /twitter.atom
    safe_expire tweets_path('.html')          # /twitter.html

    instance.expire_fragment :tweets_sidebar
  end

  def after_destroy(tweet)
    expire_cache tweet
  end

  def after_save(tweet)
    expire_cache tweet
  end

private

  def expire_cache(tweet)
    safe_expire tweet_path(tweet)           # /twitter/1.html
    safe_expire tweet_path(tweet, '.atom')  # /twitter/1.atom
    safe_expire tweets_path('.atom')        # /twitter.atom
    safe_expire tweets_path('.html')        # /twitter.html

    # /twitter/page/1.html, /twitter/page/2.html etc
    safe_expire(tweets_path + 'page', recurse: true)

    expire_fragment :tweets_sidebar
  end
end
