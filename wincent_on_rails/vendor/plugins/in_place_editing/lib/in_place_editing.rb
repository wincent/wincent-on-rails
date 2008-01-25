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
        render :update do |page|
          unless @item.save
            @item.send(attribute.to_s + '=', old_value)
            page.alert(@item.errors.full_messages.join("\n"))
          end
          page.replace_html(in_place_editor_field_id(object, attribute, params[:id]), @item.send(attribute))
        end
      end
    end
  end
end
