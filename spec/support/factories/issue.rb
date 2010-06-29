Factory.define :issue do |i|
  i.summary { Sham.random }
  i.description { Sham.random }
  i.awaiting_moderation false
end
