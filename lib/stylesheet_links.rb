module ActionController
  module StylesheetLinks
    extend ActiveSupport::Concern

    module ClassMethods
      def uses_stylesheet_links options = {}
        unless respond_to? :uses_stylesheet_links?
          class_eval <<-END
            def self.uses_stylesheet_links?; true; end
          END
        end

        if options[:only]
          unless respond_to? :included_stylesheet_link_actions
            class_eval <<-END
              @@included_stylesheet_link_actions = []
              def self.included_stylesheet_link_actions
                @@included_stylesheet_link_actions
              end
            END
          end
          [options[:only]].flatten.each do |inclusion|
            included_stylesheet_link_actions << inclusion
          end
        end

        if options[:except]
          unless respond_to? :excluded_stylesheet_link_actions
            class_eval <<-END
              @@excluded_stylesheet_link_actions = []
              def self.excluded_stylesheet_link_actions
                @@excluded_stylesheet_link_actions
              end
            END
          end
          [options[:except]].flatten.each do |exclusion|
            excluded_stylesheet_link_actions << exclusion
          end
        end
      end
    end
  end # module StylesheetLinks
end # module ActionController

ActionController::Base.class_eval { include ActionController::StylesheetLinks }
