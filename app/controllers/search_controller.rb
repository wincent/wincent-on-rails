class SearchController < ApplicationController
  def create
    @offset = params[:offset].to_i
    @models = Needle.find_using_query_string((params[:query] || ''), :offset => @offset)
  end
end
