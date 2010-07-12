module ViewSpecHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def _default_helpers
      helpers = [ApplicationHelper]
      helpers << (example.example_group.top_level_description.split('/').first.camelize + 'Helper').constantize
    rescue NameError
      helpers
    end
  end # ClassMethods

  included do
    helper *_default_helpers
  end
end # module ViewSpecHelpers
