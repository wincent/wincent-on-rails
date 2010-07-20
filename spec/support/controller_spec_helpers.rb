module ControllerSpecHelpers
  def log_in_as user
    controller.instance_eval { self.set_current_user = user }
  end

  def log_in_as_admin
    log_in_as User.make!(:superuser => true)
  end

  def as_admin &block
    log_in_as_admin
    yield
  end

  def log_in
    log_in_as User.make!
  end

  def cookie_flash
    return {} unless cookies['flash']
    ActiveSupport::JSON.decode(CGI::unescape(cookies['flash']))
  end
end
