module ControllerExampleGroupHelpers
  def log_in_as user
    stub(controller).log_in_with_cookie { user }
    stub(controller).log_in_with_http_basic { user }
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
end
