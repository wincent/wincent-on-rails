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
        begin
          @item.update_attribute!(attribute, params[:value])
        rescue ActiveRecord::RecordInvalid => e
          @item.send(attribute.to_s + '=', old_value)
          # return 444 or similar here so that AJAX can pick it up
        end
        render :text => @item.send(attribute).to_s
      end
    end
  end
end
