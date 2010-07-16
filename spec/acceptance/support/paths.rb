module NavigationHelpers
  def default_url_options; {}; end
  include Rails.application.routes.url_helpers
end

RSpec.configuration.include NavigationHelpers, :example_group => {
  :file_path => %r{\bspec/acceptance/}
}
