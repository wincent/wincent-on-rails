module RoutingSpecHelpers
  extend ActiveSupport::Concern
  extend RSpec::Matchers::DSL

  included do
    include Rails.application.routes.url_helpers
  end

  def get path
    { :method => :get, :path => path }
  end

  matcher :map_to do |destination|
    match_unless_raises Test::Unit::AssertionFailedError do |request|
      method = request[:method]
      path = request[:path]
      assert_recognizes(destination, { :method => method, :path => path })
    end

    failure_message_for_should do
      rescued_exception.message
    end
  end

  matcher :map_from do |destination|
    match_unless_raises Test::Unit::AssertionFailedError do |request|
      path = request[:path]
      assert_generates path, destination
    end

    failure_message_for_should do
      rescued_exception.message
    end
  end
end
