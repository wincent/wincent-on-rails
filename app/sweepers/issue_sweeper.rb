class IssueSweeper < ActionController::Caching::Sweeper
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

  # on-demand cache expiration from rake, RSpec etc
  def self.expire_all
    Issue.all.each do |issue|
      # Unfortunately can't just do an instance.expire_cache from here:
      # ActionController::Caching::Sweeper defines a "method_missing" method
      # that catches the "expire_cache" message and drops it on the floor
      # (it only works when the sweeper is set up from within a controller,
      # and the @controller instance variable is set; the "expire_cache"
      # message is actually forwarded to the controller)
      # regrettably, we have to resort to nasty use of "send" to send
      # messages to private methods to dynamically construct the path.
      relative_path = instance.send(:issue_path, issue) + '.atom'
      absolute_path = ActionController::Base.send(:page_cache_path, relative_path)
      File.delete absolute_path if File.exist?(absolute_path)
      # BUG: this won't catch stale files left behind on disk by rogue
      # processes (for example, when "rake spec" used to contaminate the
      # "public" directory); eventually will want to replace this with
      # something based on "rm_r" which won't even look at the database
    end
  end
end # class IssueSweeper
