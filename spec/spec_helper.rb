ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_framework = :rr
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
  config.include ControllerExampleGroupHelpers, :type => :controller
  config.include RoutingExampleGroupHelpers, :type => :routing
  config.include ViewExampleGroupHelpers, :type => :view
  config.include GitSpecHelpers, :example_group => {
    :file_path => %r{\bspec/lib/git/}
  }
  config.backtrace_clean_patterns = config.backtrace_clean_patterns + [
    %r{/Library/},
    %r{/\.bundle/}
  ]
end

# Bundler regression: http://github.com/carlhuda/bundler/issues/issue/478
# beta 1.0.0.beta.9 breaks acceptance tests involving Celerity
if ENV['RUBYOPT']
  ENV['RUBYOPT'] = ENV['RUBYOPT'].gsub(%r{-r\s*bundler/setup}, '')
end

# temporary hack: ssh sessions have an emaciated path
# (/usr/local/bin:/bin:/usr/bin) and I am not sure how to modify it
# at runtime
#
# note that we could inject into the path from script/deploy but that
# would only work for full spec runs, not isolated runs when logged
# in locally to the server:
#
#   ssh rails@$SERVER "sh -c 'cd $DEPLOY/latest && \
#                             env PATH=/usr/local/jruby/bin:\$PATH bin/rspec -f progress spec'"
#
unless ENV['PATH'].to_s =~ /jruby/
  ENV['PATH'] = ['/usr/local/jruby/bin', ENV['PATH']].join(':')
end
