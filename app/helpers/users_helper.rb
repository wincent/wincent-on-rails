module UsersHelper
  def email_status email
    statuses = [email.verified? ? 'verified' : 'unverified']
    statuses << 'deleted' if email.deleted?
    "(#{statuses.join(', ')})"
  end
end
