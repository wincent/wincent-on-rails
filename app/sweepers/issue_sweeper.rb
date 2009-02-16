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

  # on-demand cache expiration from rake, RSpec etc
  def self.expire_all
    # BUG: Would be nice if this worked but unfortunately it doesn't:
    # the "expire_page" message is sent, but never received
    # (logging in both "expire_page" methods defined by Rails prints nothing)
    # so there is some "magic" somewhere preventing this from working
    sweeper = new
    Issue.all.each { |issue| sweeper.expire_cache issue }
  end
end # class IssueSweeper
