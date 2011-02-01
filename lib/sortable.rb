module ActionController
  module Acts
    module Sortable
      extend ActiveSupport::Concern

      module ClassMethods
        def acts_as_sortable options = {}
          sortable_attributes = (options[:by] || []).map do |attr|
            attr.to_s
          end

          define_method :sortable_attributes do
            sortable_attributes
          end
          private :sortable_attributes

          if options[:default]
            order = options[:descending] ? 'DESC' : 'ASC'
            default_attributes = "#{options[:default].to_s} #{order}"
          else
            default_attributes = ''
          end

          define_method :default_sort_options do
            default_attributes
          end
          private :default_sort_options
        end
      end # module ClassMethods

      def sort_options
        if sortable_attributes.include? params[:sort]
          @sort_by = params[:sort]  # for use in view
          if params[:order] and params[:order].downcase == 'desc'
            @sort_descending = true # for use in view
            "#{params[:sort]} DESC"
          else
            params[:sort]
          end
        else
          default_sort_options
        end
      end
      private :sort_options
    end # module Sortable
  end # module Acts
end # module ActionController

module ActionView
  module Helpers
    module SortableHelper

      # Note that this is designed to play nicely with the paginator and
      # controllers which might set params, preserving the custom params in the
      # query string if set
      def sortable_header_cell attribute_name, display_name = nil
        attribute_name          = attribute_name.to_s
        display_name            ||= attribute_name
        css_class_options       = {}
        url_options             = { :sort => attribute_name, :order => 'asc' }
        url_options             = params.merge(url_options)
        url_options.delete(:authenticity_token) # not needed for GET requests
        tooltip                 = { :title => "Click to sort by #{display_name}" }
        if @sort_by == attribute_name # boldface this attribute
          tooltip               = { :title => 'Click to toggle sort order'}
          if @sort_descending
            css_class_options   = { :class => 'descending' }
          else
            css_class_options   = { :class => 'ascending' }
            url_options[:order] = 'desc'
          end
        end
        content_tag :th, css_class_options do
          link_to(display_name, url_for(url_options), tooltip)
        end
      end
    end # module SortableHelper
  end # module Helpers
end # module ActionView

ActionController::Base.class_eval { include ActionController::Acts::Sortable }
ActionView::Base.class_eval       { include ActionView::Helpers::SortableHelper }
