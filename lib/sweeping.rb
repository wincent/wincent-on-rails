# Routing helpers aren't available in sweepers, and their behavior has
# historically been inconsistent across different Rails versions, resulting in
# countless hours of pain over the years (just `git log -p -- app/sweepers` for
# a sense of how much churn has been required in this area to keep up with Rails
# upgrades), so here we hand-roll some helpers that will hopefully isolate us
# from changes in Rails in the future.
#
# In Rails 4 with the extraction of the rails-observers gem, more breakage
# ensued, this time around `#expire_fragment`. This has always behaved insanely,
# so we just overwrite it here with a mad hack. For more context, see:
#
#   https://github.com/rails/rails/issues/9349
#   https://github.com/rails/rails/issues/8129
#
module Sweeping

  # Note: we can't use `#to_param` everywhere here as it will return nil for
  # just-destroyed records without custom `#to_param` implementations (models
  # like Issue, Snippet and Tweet which just use `#id` as their param). It works
  # fine, however, for models like Article, Forum, Post and Product which use
  # permalinks or other non-id strategies.
  #
  # While all this may seem very brittle, on the bright side the URLs in this
  # application tend to be very stable as, historically, I've placed a lot of
  # weight on getting the URL design right the first time.

private

  def expire_fragment(*args)
    # Yes, a terrible hack, but ApplicationController is where the method is
    # defined (via a mix-in from ActionController::Caching::Fragments), and
    # Sweepers work in a scary way (delegating `#method_missing` to
    # `@controller` if set). The only way to be sure this thing will always
    # actually expire a fragment is this ghastly hack:
    ApplicationController.new.expire_fragment(*args)
  end

  def article_path(article, ext = '.atom')
    articles_path + (article.to_param + ext)
  end

  def articles_path(ext = '')
    Rails.root + ('public/wiki' + ext)
  end

  def forum_topic_path(forum, topic, ext = '.atom')
    Rails.root + 'public/forums' + forum.to_param + 'topics' + topic.id.to_s
  end

  def issue_path(issue, ext = '.atom')
    issues_path + (issue.id.to_s + ext)
  end

  def issues_path(ext = '')
    Rails.root + ('public/issues' + ext)
  end

  def product_path(product, ext = '')
    products_path + (product.to_param + ext)
  end

  def products_path(ext = '')
    Rails.root + ('public/products' + ext)
  end

  def post_path(post, ext = '.atom')
    posts_path + (post.to_param + ext)
  end

  def posts_path(ext = '')
    Rails.root + ('public/blog' + ext)
  end

  def snippet_path(snippet, ext = '.html')
    snippets_path + (snippet.id.to_s + ext)
  end

  def snippets_path(ext = '')
    Rails.root + ('public/snippets' + ext)
  end

  def tweet_path(tweet, ext ='.html')
    tweets_path + (tweet.id.to_s + ext)
  end

  def tweets_path(ext = '')
    Rails.root + ('public/twitter' + ext)
  end

  def safe_expire(pathname, opts = {})
    return unless pathname.exist?
    opts[:recurse] ? pathname.rmtree : pathname.delete
  rescue Errno::ENOENT
    # race resilience
  end
end # module Sweeping
