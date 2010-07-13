module ViewSpecHelpers
  extend ActiveSupport::Concern

  module ClassMethods
    def _default_helper
      base = metadata[:behaviour][:description].split('/').first
      (base.camelize + 'Helper').constantize if base
    rescue NameError
      nil
    end

    def _default_helpers
      helpers = [_default_helper].compact
      helpers << ApplicationHelper if Object.const_defined?('ApplicationHelper')
      helpers
    end
  end # ClassMethods

  included do
    helper *_default_helpers
  end
end # module ViewSpecHelpers
