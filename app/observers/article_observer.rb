class ArticleObserver < ActiveRecord::Observer
  class << self
    # For "redlink" support in wikitext.
    def known_links
      instance.known_links
    end
  end

  def after_destroy(article)
    @known_links = nil # not too worried about the thundering herd here
  end

  def after_save(article)
    @known_links = nil # not too worried about the thundering herd here
  end

  def known_links
    @known_links ||= Set.new(Article.pluck(:title).map(&:downcase))
  end
end
