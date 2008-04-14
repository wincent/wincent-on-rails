module Classifiable
  def moderate_as_spam!
    moderate! true
  end

  def moderate_as_ham!
    moderate! false
  end

protected

  def moderate! is_spam
    # we don't want moderating a model to mark it as updated, so use update_all
    self.awaiting_moderation  = false
    self.spam                 = is_spam
    self.class.update_all ['awaiting_moderation = FALSE, spam = ?', is_spam], ['id = ?', self.id]
  end
end # module Classifiable
