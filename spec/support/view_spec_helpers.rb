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

    @@helper_hack_done = false
    before do
      if not @@helper_hack_done
        view.instance_eval do
          self.class.send(:include, @controller._helpers)
        end
        @@helper_hack_done = true
      end
    end
  end
end # module ViewSpecHelpers
