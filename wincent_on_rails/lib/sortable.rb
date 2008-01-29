module ActionController
  module Acts
    module Sortable
      def self.included base
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_sortable options = {}
          if options[:by]
            sortable_attributes = options[:by].map { |a| a.to_s }
          else
            sortable_attributes = []
          end
          sortable_attributes = sortable_attributes.map { |a| "\"#{a}\""}
          sortable_attributes = sortable_attributes.join ", "

          class_eval <<-END
              def sortable_attributes
                [#{sortable_attributes}]
              end
            END

          include ActionController::Acts::Sortable::InstanceMethods
          extend ActionController::Acts::Sortable::ClassMethods
        end
      end # module ClassMethods

      # no class methods yet: may potentially add some later
      module ClassMethods; end

      module InstanceMethods
        def sort_options
          options = {}
          if self.sortable_attributes.include? params[:sort]
            @sort_by = params[:sort]  # for use in view
            if params[:order] and params[:order].downcase == 'desc'
              @sort_descending = true # for use in view
              options = { :order => "#{params[:sort]} DESC" }
            else
              options = { :order => params[:sort] }
            end
          end
          options
        end
      end # module InstanceMethods
    end # module Sortable
  end # module Acts
end # module ActionController

module ActionView
  module Helpers
    module SortableHelper
      # TODO: localize these strings
      def sortable_header_cell attribute_name, display_name = nil
        attribute_name    = attribute_name.to_s
        display_name      ||= attribute_name
        css_class_options = {}
        url               = url_for(:action => params[:action], :controller => params[:controller], :sort => attribute_name)
        tooltip           = { :title => "Click to sort by #{display_name}" }
        if @sort_by == attribute_name # boldface this attribute
          tooltip         = { :title => "Click to toggle sort order"}
          if @sort_descending
            css_class_options = { :class => 'descending' }
          else
            css_class_options = { :class => 'ascending' }
            url = url_for(:action => params[:action], :controller => params[:controller], :sort => attribute_name,
              :order => 'desc')
          end
        end
        open :th, css_class_options do
          puts link_to(display_name, url, tooltip)
        end
      end
    end # module SortableHelper
  end # module Helpers
end # module ActionView

ActionController::Base.class_eval { include ActionController::Acts::Sortable }
ActionView::Base.class_eval       { include ActionView::Helpers::SortableHelper }