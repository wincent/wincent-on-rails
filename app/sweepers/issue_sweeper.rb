class IssueSweeper < ActionController::Caching::Sweeper

  # NOTE: routing helpers (issue_path etc) won't work if you declare a multi-model sweeper, so beware!
  observe Issue

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
