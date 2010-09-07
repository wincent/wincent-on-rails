require File.expand_path('../factory_girl.rb', File.dirname(__FILE__))
require 'spec_helper'

Factory.define :repo do |r|
  include GitSpecHelpers

  r.name { Sham.random }
  r.permalink { Sham.random }
  r.path { scratch_repo }
end
