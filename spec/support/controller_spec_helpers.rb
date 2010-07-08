module ControllerSpecHelpers
  def login_as user
    controller.instance_eval { @current_user = user }
    stub(controller).login_before # don't let the before filter clear the user again
  end

  def login_as_admin
    controller.instance_eval { @current_user = User.make! :superuser => true }
    stub(controller).login_before # don't let the before filter clear the user again
  end

  def as_admin &block
    login_as_admin
    yield
  end

  def login_as_normal_user
    login_as User.make!
  end

  def cookie_flash
    return {} unless cookies['flash']
    ActiveSupport::JSON.decode(CGI::unescape(cookies['flash']))
  end
end
