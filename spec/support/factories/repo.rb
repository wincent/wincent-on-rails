require File.expand_path('../factory_girl.rb', File.dirname(__FILE__))
require File.expand_path('../git_spec_helpers.rb', File.dirname(__FILE__))

Factory.define :repo do |r|
  include GitSpecHelpers

  r.name { Sham.random }
  r.permalink { Sham.random }
  r.path { scratch_repo }
end
