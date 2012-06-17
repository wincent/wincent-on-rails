class SnippetSweeper < ActionController::Caching::Sweeper
  observe Snippet

  extend  Sweeping
  include Sweeping

  # on-demand cache expiration from Rake (`rake cache:clear`), RSpec etc
  def self.expire_all
    safe_expire snippets_path, :recurse => true # /snippets/**/*
    safe_expire snippets_path('.atom')          # /snippets.atom
    safe_expire snippets_path('.html')          # /snippets.html
  end

  def after_destroy(snippet)
    expire_cache snippet
  end

  def after_save(snippet)
    expire_cache snippet
  end

private

  def expire_cache(snippet)
    safe_expire snippet_path(snippet)           # /snippets/1.html
    safe_expire snippet_path(snippet, '.atom')  # /snippets/1.atom
    safe_expire snippet_path(snippet, '.txt')   # /snippets/1.txt
    safe_expire snippets_path('.atom')          # /snippets.atom
    safe_expire snippets_path('.html')          # /snippets.html

    # /snippet/page/1.html, /snippet/page/2.html etc
    safe_expire(snippets_path + 'page', :recurse => true)
  end
end
