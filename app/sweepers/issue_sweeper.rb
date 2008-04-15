class IssueSweeper < ActionController::Caching::Sweeper
  observe Issue

  # routing helpers (issue_path etc) _might_ not work without this include (behaviour seems erratic)
  include ActionController::UrlWriter

  def after_destroy issue
    expire_cache issue
  end

  def after_save issue
    expire_cache issue
  end

  def expire_cache issue
    expire_page(issue_path(issue) + '.atom')
  end
end # class IssueSweeper
