# custom additions to "env.rb" file
require 'fixture_replacement'
include FixtureReplacement

require 'capybara/rails'
require 'capybara/cucumber'
Capybara.javascript_driver = :culerity

require 'database_cleaner'
require 'database_cleaner/cucumber'
DatabaseCleaner.strategy = :truncation
