class SearchController < ApplicationController
  # This is somewhat of an abuse of RESTful resource routing:
  # both the "index" and "new" actions render the search form
  # and the "create" action is used to display the results.
  def create
    @offset = params[:offset].to_i
    @models = Needle.find_using_query_string((params[:query] || ''), :offset => @offset)
  end
end
