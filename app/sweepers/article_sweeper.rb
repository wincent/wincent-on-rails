class ArticleSweeper < ActionController::Caching::Sweeper
  observe Article

  def after_destroy article
    expire_cache
  end

  def after_save article
    expire_cache
  end

  # note that the html indexes _don't_ get updated whenever tags change
  # as the top tags should change only infrequently
  def expire_cache
    Dir[File.join(RAILS_ROOT, 'public', 'wiki', '*.html')].each { |page| expire_page(page) }
    expire_page(wiki_index_path + '.atom')
  end
end # class TopicSweeper
