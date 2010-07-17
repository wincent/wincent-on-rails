module ControllerSpecHelpers
  def log_in_as user
    controller.instance_eval { @current_user = user }
    stub(controller).log_in_before # don't let the before filter clear the user again
  end

  def log_in_as_admin
    controller.instance_eval { @current_user = User.make! :superuser => true }
    stub(controller).log_in_before # don't let the before filter clear the user again
  end

  def as_admin &block
    log_in_as_admin
    yield
  end

  def log_in_as_normal_user
    log_in_as User.make!
  end

  def cookie_flash
    return {} unless cookies['flash']
    ActiveSupport::JSON.decode(CGI::unescape(cookies['flash']))
  end
end
