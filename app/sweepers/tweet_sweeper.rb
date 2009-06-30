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

  # on-demand cache expiration from rake
  def self.expire_all
    # see the notes in the IssueSweeper for full explanation of why we do it this way
    relative_path   = instance.send :tweets_path
    index_path      = ActionController::Base.send(:page_cache_directory) + relative_path
    atom_index_path = index_path + '.atom'
    html_index_path = index_path + '.html'
    page_dir        = index_path + '/page'
    File.delete(atom_index_path) if File.exist?(atom_index_path)  # twitter.atom
    File.delete(html_index_path) if File.exist?(html_index_path)  # twitter.html

    # twitter/2.html, twitter/2.atom etc
    File.delete(*Dir["#{index_path}/*.html"]) if File.exist?(index_path)
    File.delete(*Dir["#{index_path}/*.atom"]) if File.exist?(index_path)

    # twitter/page/2.html, twitter/page/3.html etc
    File.delete(*Dir["#{page_dir}/*.html"]) if File.exist?(page_dir)
  end
end
