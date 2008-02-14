module Commentable

  # All comments which have passed moderation and are not flagged as spam.
  def published
    find(:all, :conditions => { :awaiting_moderation => false, :spam => false})
  end

  # Returns all comments for this record which haven't yet been moderated and are not marked as spam.
  def unmoderated
    find(:all, :conditions => { :awaiting_moderation => true, :spam => false})
  end

  # All comments which have not been flagged as spam (both moderated and unmoderated).
  def ham
    find_all_by_spam(false)
  end

  # All comments which have been flagged as spam.
  def spam
    find_all_by_spam(true)
  end

  # The count of all published (not awaiting moderation, not flagged as spam) comments.
  def published_count
    count(:conditions => 'awaiting_moderation = false AND spam = false')
  end

  # The count of comments awaiting moderation.
  def unmoderated_count
    count(:conditions => 'awaiting_moderation = true')
  end

  def ham_count
    count(:conditions => 'spam = false')
  end

  # The count of comments that have been flagged as spam.
  def spam_count
    count(:conditions => 'spam = true')
  end
end
