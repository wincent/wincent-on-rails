Factory.define :comment do |c|
  c.association :user
  c.sequence(:body) { |n| "Comment #{n}." }
  c.association :commentable, :factory => :article
  c.awaiting_moderation false
end
