module UsersHelper
  def editable &block
    if logged_in? && @user == current_user || admin?
      simple_concat &block
    end
  end
end
