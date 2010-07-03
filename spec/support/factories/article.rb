Factory.define :article do |a|
  a.title { Sham.random }
  a.body { Sham.lorem_ipsum }
end
