require File.expand_path('../factory_girl', File.dirname(__FILE__))
require File.expand_path('../git_spec_helpers', File.dirname(__FILE__))
require 'spec_helper'

Factory.define :repo do |r|
  include GitSpecHelpers

  r.name { Sham.random }
  r.permalink { Sham.random }
  r.path { scratch_repo }
  r.public { true } # defaults to false, but true is more useful for testing
end
