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
  #   # note that :post here names an instance variable, @post
  #   # (normal local variables won't work)
  #   <%= in_place_editor_field :post, 'title' %>
  #
  module ClassMethods
    def in_place_edit_for(object, attribute, options = {})
      define_method("set_#{object}_#{attribute}") do
        unless [:post, :put].include?(request.method) then
          return render(:text => 'Method not allowed', :status => 405)
        end
        @item = object.to_s.camelize.constantize.find(params[:id])
        old_value = @item.send(attribute)
        @item.send(attribute.to_s + '=', params[:value])
        render :update do |page|
          unless @item.save
            # here we restore the old value; comment this out to leave the old value in place for further editing
            # (with special case perhaps for empty strings, which aren't clickable)
            #  tried to default to this, but couldn't find a way to keep the editor field active
            @item.send(attribute.to_s + '=', old_value)
            page.alert(@item.errors.full_messages.join("\n"))
          end
          field_id = in_place_editor_field_id(object, attribute, params[:id])
          page.replace_html(in_place_editor_field_id(object, attribute, params[:id]), CGI::escapeHTML(@item.send(attribute).to_s))

          # we return early from the enterEditMode function because self._saving and self._editing return true
          #page.call "#{field_id}_var.leaveEditMode"
          # calling leaveEditMode doesn't seem to fix the issue
          # this works when single stepping in Firebug, but the editor gets removed immediately afterwards
          #page.call "#{field_id}_var.enterEditMode"
        end
      end
    end
  end
end
