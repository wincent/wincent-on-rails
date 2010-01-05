# custom additions to "env.rb" file
require 'fixture_replacement'
include FixtureReplacement
Capybara.javascript_driver = :culerity
