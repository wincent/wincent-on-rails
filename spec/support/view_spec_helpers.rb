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
    metaclass = class << view; self; end
    unless metaclass.included_modules.include?(controller._helpers)
      metaclass.__send__(:include, controller._helpers)
    end
  end

  included do
    helper *_default_helpers

    before do
      _include_controller_helpers
    end
  end
end # module ViewSpecHelpers
