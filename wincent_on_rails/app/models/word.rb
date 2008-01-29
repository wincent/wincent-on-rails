class Word < ActiveRecord::Base
  SPAM            = 1 # classifier for words that appear in spam
  SUPPORT_TICKET  = 2 # classifier for words that appear in support tickets
  FEATURE_REQUEST = 3 # classifier for words that appear in feature requests
  BUG_REPORT      = 4 # classifier for words that appear in bug reports
  FEEDBACK        = 5 # classifier for words that appear in feedback

  # Expects a block of input text and a classification.
  # On training a message need to increment the message count someone (not in this table, therefore need another model).
  # Perhaps this needs to be dynamic: a Classifications table.
  # And perhaps this needs to be called the Token model, not the Word model (or is that splitting hairs?).
  # Finally, if we have two models, need to decide where the train and tokenize methods go (probably here is the right place).
  def self.train input, classification

  end

  # Tokenizes a block of input text into individual "words", returning them in an array.
  def self.tokenize input

  end
end
