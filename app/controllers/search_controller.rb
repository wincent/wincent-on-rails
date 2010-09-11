class SearchController < ApplicationController
  uses_stylesheet_links

  def search
    unless params[:q].blank?
      @offset = params[:offset].to_i
      @query  = params[:q]
      @models = Needle.find_with_query_string @query,
                                              :offset => @offset,
                                              :user => current_user
    end
  end
end
