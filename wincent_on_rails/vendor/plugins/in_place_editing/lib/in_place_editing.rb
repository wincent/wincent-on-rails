module InPlaceEditing
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Example:
  #
  #   # Controller
  #   class BlogController < ApplicationController
  #     in_place_edit_for :post, :title
  #   end
  #
  #   # View
  #   <%= in_place_editor_field :post, 'title' %>
  #
  module ClassMethods
    def in_place_edit_for(object, attribute, options = {})
      define_method("set_#{object}_#{attribute}") do
        @item = object.to_s.camelize.constantize.find(params[:id])
        old_value = @item.send(attribute)
        @item.send(attribute.to_s + '=', params[:value])

        # format will be something like: locale_description_1_in_place_editor
        render :update do |page|
          unless @item.save
            @item.send(attribute.to_s + '=', old_value)
            page.alert(@item.errors.full_messages.join("\n"))
          end
          page.replace_html("#{object}_#{attribute}_#{params[:id]}_in_place_editor", @item.send(attribute))
        end
      end
    end
  end
end
