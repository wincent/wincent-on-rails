class IssueSweeper < ActionController::Caching::Sweeper
  observe Issue

  extend  Sweeping
  include Sweeping

  # on-demand cache expiration from Rake (`rake cache:clear`), RSpec etc
  def self.expire_all
    safe_expire issues_path
  end

  def after_destroy issue
    expire_cache issue
  end

  def after_save issue
    expire_cache issue
  end

private

  def expire_cache issue
    safe_expire issue_path(issue) # /issues/1.atom
  end
end # class IssueSweeper
