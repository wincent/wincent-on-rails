class SnippetSweeper < ActionController::Caching::Sweeper
  observe Snippet

  # Rails BUG: https://rails.lighthouseapp.com/projects/8994/tickets/4868
  include Rails.application.routes.url_helpers

  def after_destroy snippet
    expire_cache snippet
  end

  def after_save snippet
    expire_cache snippet
  end

  def expire_cache snippet
    expire_page(snippet_path(snippet) + '.html')  # snippets/1.html
    expire_page(snippet_path(snippet) + '.atom')  # snippets/1.atom
    expire_page(snippet_path(snippet) + '.txt')   # snippets/1.txt
    expire_page(snippets_path + '.html')          # snippets.html
    expire_page(snippets_path + '.atom')          # snippets.atom

    # now snippet/page/1.html, snippet/page/2.html etc
    page_dir = ActionController::Base.send(:page_cache_directory) +
      snippets_path + '/page'
    FileUtils.rm_rf(page_dir)
  end

  # on-demand cache expiration from rake (rake cache:clear)
  def self.expire_all
    # see the notes in the IssueSweeper for full explanation of why we do it
    # this way
    relative_path = instance.send :snippets_path
    index_path = ActionController::Base.send(:page_cache_directory) +
      relative_path

    # snippets, snippets.atom, snippets.html
    # snippets/2.html, snippets/2.atom etc
    # snippets/page/2.html, snippets/page/3.html etc
    FileUtils.rm_rf(Dir["#{index_path}*"])
  end
end
