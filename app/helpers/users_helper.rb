module UsersHelper
  # similar helpers will work for any model that has a "user" (or owner) association
  def editable &block
    if logged_in? && @user == current_user || admin?
      yield
    end
  end

  def email_status email
    statuses = [email.verified? ? 'verified' : 'unverified']
    statuses << 'deleted' if email.deleted?
    "(#{statuses.join(', ')})"
  end
end
