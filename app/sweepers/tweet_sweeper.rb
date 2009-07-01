class TweetSweeper < ActionController::Caching::Sweeper
  observe Tweet

  # routing helpers (tweets_path etc)
  include ActionController::UrlWriter

  def after_destroy tweet
    expire_cache tweet
  end

  def after_save tweet
    expire_cache tweet
  end

  def expire_cache tweet
    # BUG: these "expire_page" methods fire in specs but do nothing
    # (presumably because @controller is nil, method_missing does nothing)
    # likewise, "page_cache_directory" returns nil in specs unless we do the
    # ActionController::Base.send trick
    # Very ugly; not sure if I want to add a "return if ... nil"
    expire_page(tweet_path(tweet) + '.html')  # twitter/321.html
    expire_page(tweet_path(tweet) + '.atom')  # twitter/321.atom
    expire_page(tweets_path + '.atom')        # twitter.atom
    expire_page(tweets_path + '.html')        # twitter.html
    expire_fragment :tweets_sidebar

    # now twitter/page/1.html, twitter/page/2.html etc
    page_dir = ActionController::Base.send(:page_cache_directory) + tweets_path + '/page'
    if File.exist? page_dir
      File.delete(*Dir["#{page_dir}/*.html"])
    end
  end

  # on-demand cache expiration from rake (rake cache:clear)
  def self.expire_all
    # see the notes in the IssueSweeper for full explanation of why we do it this way
    relative_path   = instance.send :tweets_path
    index_path      = ActionController::Base.send(:page_cache_directory) + relative_path

    # twitter, twitter.atom, twitter.html
    # twitter/2.html, twitter/2.atom etc
    # twitter/page/2.html, twitter/page/3.html etc
    FileUtils.rm_rf(Dir["#{index_path}*"])
  end
end
