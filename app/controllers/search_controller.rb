class SearchController < ApplicationController
  # make search form work even from static 404 pages etc
  # (which don't have an authenticity token)
  skip_before_filter :verify_authenticity_token

  # This is somewhat of an abuse of RESTful resource routing:
  # both the "index" and "new" actions render the search form
  # and the "create" action is used to display the results.
  def create
    @offset = params[:offset].to_i
    @models = Needle.find_using_query_string((params[:query] || ''), :offset => @offset, :user => current_user)
  end
end
