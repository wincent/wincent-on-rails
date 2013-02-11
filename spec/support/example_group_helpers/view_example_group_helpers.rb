module ViewExampleGroupHelpers
  extend ActiveSupport::Concern

  module ClassMethods
  end # ClassMethods

  included do
  end

  def within(*args)
    yield Capybara.string(rendered).find(*args)
  end
end # module ViewSpecHelpers
