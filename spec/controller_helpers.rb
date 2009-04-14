module ControllerHelpers
  def login_as user
    controller.instance_eval { @current_user = user }
    controller.stub!(:login_before) # don't let the before filter clear the user again
  end

  def login_as_admin
    controller.instance_eval { @current_user = create_user :superuser => true }
    controller.stub!(:login_before) # don't let the before filter clear the user again
  end

  def login_as_normal_user
    login_as create_user
  end

  def cookie_flash
    return {} unless cookies['flash']
    ActiveSupport::JSON.decode(CGI::unescape(cookies['flash']))
  end
end
