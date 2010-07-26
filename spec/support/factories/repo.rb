require File.expand_path('../factory_girl.rb', File.dirname(__FILE__))

Factory.define :repo do |r|
  r.name { Sham.random }
  r.permalink { Sham.random }
  r.path { Rails.root.to_s }
end
