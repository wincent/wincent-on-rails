Factory.define :topic do |t|
  t.association :forum
  t.title { Sham.random }
  t.body { Sham.lorem_ipsum }
  t.awaiting_moderation false
end
