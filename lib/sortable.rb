module ActionController
  module Acts
    module Sortable
      extend ActiveSupport::Concern

      module ClassMethods
        def acts_as_sortable options = {}
          if options[:by]
            sortable_attributes = options[:by].map { |a| a.to_s }
          else
            sortable_attributes = []
          end
          sortable_attributes = sortable_attributes.map { |a| "'#{a}'" }.join(', ')

          if options[:default]
            order = (options[:descending] == true) ? 'DESC' : 'ASC'
            default_attributes = %Q{:order => "#{options[:default].to_s} #{order}"}
          else
            default_attributes = ''
          end

          # here we define methods: could also use class_variable_set
          class_eval <<-END
              def sortable_attributes
                [#{sortable_attributes}]
              end

              def default_sort_options
                {#{default_attributes}}
              end
            END
        end
      end # module ClassMethods

      def sort_options
        if sortable_attributes.include? params[:sort]
          @sort_by = params[:sort]  # for use in view
          if params[:order] and params[:order].downcase == 'desc'
            @sort_descending = true # for use in view
            options = { :order => "#{params[:sort]} DESC" }
          else
            options = { :order => params[:sort] }
          end
        else
          options = default_sort_options
        end
        options
      end
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
