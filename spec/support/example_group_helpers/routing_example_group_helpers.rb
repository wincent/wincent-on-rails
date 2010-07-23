module RoutingExampleGroupHelpers
  extend ActiveSupport::Concern
  extend RSpec::Matchers::DSL

  module DestinationParser
    def parse_destination destination
      string_or_hash, options_hash = destination[0], destination[1]
      case string_or_hash
      when String
        controller, action = string_or_hash.split('#')
        options = options_hash || {}
        options.merge({ :controller => controller, :action => action })
      when Hash
        string_or_hash
      else
        raise ArgumentError.new "unexpected argument of class #{destination.class}"
      end
    end
  end

  included do
    include Rails.application.routes.url_helpers
  end

  def delete path
    { :method => :delete, :path => path }
  end

  def get path
    { :method => :get, :path => path }
  end

  def post path
    { :method => :post, :path => path }
  end

  def put path
    { :method => :put, :path => path }
  end

  matcher :map_to do |*destination|
    extend DestinationParser

    match_unless_raises Test::Unit::AssertionFailedError do |request|
      @request = request
      @method = @request.delete :method
      @path = @request.delete :path
      @destination = parse_destination destination
      assert_recognizes(@destination, { :method => @method, :path => @path })
    end

    failure_message_for_should do
      rescued_exception.message
    end

    description do
      controller = @destination.delete(:controller)
      action = @destination.delete(:action)
      result = "map #{@method.to_s.upcase} #{@path} "
      result << " with #{@request.inspect} " unless @request.empty?
      result << "to #{controller}\##{action}"
      result << " with #{@destination.inspect}" unless @destination.empty?
      result
    end
  end

  matcher :map_from do |*destination|
    extend DestinationParser

    match_unless_raises Test::Unit::AssertionFailedError do |request|
      @request = request
      @method = @request.delete :method # ignored
      @path = @request.delete :path
      @destination = parse_destination destination
      assert_generates @path, @destination
    end

    failure_message_for_should do
      rescued_exception.message
    end

    description do
      controller = @destination.delete(:controller)
      action = @destination.delete(:action)
      result = "map #{@path} "
      result << " with #{@request.inspect} " unless @request.empty?
      result << "from #{controller}\##{action}"
      result << " with #{@destination.inspect}" unless @destination.empty?
      result
    end
  end

  matcher :have_routing do |*destination|
    extend DestinationParser

    match_unless_raises Test::Unit::AssertionFailedError do |request|
      @request = request
      @method = @request.delete :method
      @path = @request.delete :path
      @destination = parse_destination destination
      assert_routing({ :method => @method, :path => @path}, @destination)
    end

    failure_message_for_should do
      rescued_exception.message
    end

    description do
      controller = @destination.delete(:controller)
      action = @destination.delete(:action)
      result = "route #{@method.to_s.upcase} #{@path} "
      result << " with #{@request.inspect} " unless @request.empty?
      result << "as #{controller}\##{action}"
      result << " with #{@destination.inspect}" unless @destination.empty?
      result
    end
  end

  matcher :be_recognized do
    match do |request|
      @method = request[:method]
      @path = request[:path]
      @result = true

      # we need to do this because recognize_path() can still "recognize"
      # paths which aren't actually routable:
      #
      #  route:
      #    resource :issues, :except => :index
      #
      #  assertion:
      #    recognize_path('/issues', :method => :get)
      #
      #  "routes" to:
      #    {:controller => 'issues', :action => 'new'}
      begin
        assert_recognizes({}, { :method => @method, :path => @path })
      rescue ActionController::RoutingError => e
        @result = e.message
      rescue Test::Unit::AssertionFailedError => e
        # routable but we didn't supply an expected destination
      end
      @result == true
    end

    failure_message_for_should do
      @result
    end

    failure_message_for_should_not do
      "expected #{@method.to_s.upcase} #{@path} to not be routable, but it is"
    end

    description do
      "recognize #{@method.to_s.upcase} #{@path}"
    end
  end
end
