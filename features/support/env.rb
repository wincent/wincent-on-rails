ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'
require 'cucumber/formatters/unicode'
require 'webrat'
require 'cucumber/rails/rspec'

include FixtureReplacement

require 'json'

# evidently, response.request doesn't exist when running under Selenium
# undefined method `request' for #<Webrat::SeleniumResponse:0x36fad58> (NoMethodError)
module CacheableFlash
  def cacheable_flash
    json = response.request.cookies['flash']
    if json
      JSON.parser.new(json).parse
    else
      {}
    end
  end
end

World(CacheableFlash)

module Wincent
  module Test
    def self.truncate_all_tables
      connection.tables.each do |table|
        connection.execute "TRUNCATE TABLE #{table};"
      end
    end

    def self.connection
      ::ActiveRecord::Base.connection
    end
  end
end
