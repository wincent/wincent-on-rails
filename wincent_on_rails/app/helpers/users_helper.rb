module UsersHelper
  # similar helpers will work for any model that has a "user" (or owner) association
  def editable &block
    if logged_in? && @user == current_user || admin?
      yield
    end
  end
end
