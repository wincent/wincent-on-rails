module Classifiable
  def moderate_as_spam!
    moderate! true
  end

  def moderate_as_ham!
    moderate! false
    update_caches_after_moderation_as_ham if respond_to?(:update_caches_after_moderation_as_ham)
  end

protected

  # BUG: this kind of modification won't trigger any cache sweepers, which means that feeds might get out of date
  # may need to manually trigger sweepers
  def moderate! is_spam
    # we don't want moderating a model to mark it as updated, so use update_all
    self.awaiting_moderation  = false
    self.spam                 = is_spam
    self.class.update_all ['awaiting_moderation = FALSE, spam = ?', is_spam], ['id = ?', self.id]

    # I don't really like intertwining the classifiable and searchable functionality,
    # but seems to be a necessary evil for now
    # could possibly provide an optional callback here to make things slightly cleaner
    update_needles if self.class.private_method_defined? :update_needles
  end
end # module Classifiable
