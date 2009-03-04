module ActionController
  module DynamicJavascript
    def self.included base
      base.extend(ClassMethods)
    end

    module ClassMethods
      def uses_dynamic_javascript options = {}
        if options[:only]
          unless respond_to? :included_dynamic_javascript_actions
            class_eval <<-END
              @@included_dynamic_javascript_actions = []
              def self.included_dynamic_javascript_actions
                @@included_dynamic_javascript_actions
              end
            END
          end
          [options[:only]].flatten.each do |inclusion|
            included_dynamic_javascript_actions << inclusion
          end
        end
        if options[:except]
          unless respond_to? :excluded_dynamic_javascript_actions
            class_eval <<-END
              @@excluded_dynamic_javascript_actions = []
              def self.excluded_dynamic_javascript_actions
                @@excluded_dynamic_javascript_actions
              end
            END
          end
          [options[:except]].flatten.each do |exclusion|
            excluded_dynamic_javascript_actions << exclusion
          end
        end
      end
    end
  end # module DynamicJavascript
end # module ActionController

ActionController::Base.class_eval { include ActionController::DynamicJavascript }
