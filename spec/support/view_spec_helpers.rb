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

  def _include_controller_helpers
    helpers = controller._helpers
    view.singleton_class.class_eval do
      include helpers unless included_modules.include?(helpers)
    end
  end

  included do
    helper *_default_helpers

    before do
      _include_controller_helpers
    end
  end
end # module ViewSpecHelpers
