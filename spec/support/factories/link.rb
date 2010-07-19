require File.expand_path('../factory_girl.rb', File.dirname(__FILE__))

Factory.define :link do |l|
  l.uri { "http://#{Sham.random}/#{Sham.random}" }
  l.permalink { Sham.random }
end
