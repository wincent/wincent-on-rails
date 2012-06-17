require File.expand_path('../factory_girl', File.dirname(__FILE__))
require File.expand_path('../git_spec_helpers', File.dirname(__FILE__))
require 'spec_helper'

FactoryGirl.define do
  factory :repo do |r|
    name { Sham.random }
    permalink { Sham.random }
    path { GitSpecHelpers.scratch_repo }
    public { true } # defaults to false, but true is more useful for testing
  end
end
