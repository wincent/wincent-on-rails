Factory.define :tweet do |t|
  t.body { Sham.lorem_ipsum[0..139] }
end
