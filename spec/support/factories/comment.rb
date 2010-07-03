Factory.define :comment do |c|
  c.association :user
  c.body { Sham.lorem_ipsum }
  c.association :commentable, :factory => :article
  c.awaiting_moderation false
end
