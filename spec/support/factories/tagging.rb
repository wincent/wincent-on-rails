Factory.define :tagging do |t|
  t.association :tag
  t.association :taggable, :factory => :article
end
