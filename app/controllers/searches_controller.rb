# This is not a "real" resource in the sense that it does not have any
# database-backed model behind it. We nevertheless treat it as a RESTful
# resource in order to get some convenient URL helpers:
#
#   - searches#new (GET /search/new) displays the search form
#   - searches#create (POST to /search) actually performs the search and
#     displays the result
#
# In the future may decide to add a database model which records all searches,
# in which case searches#index will become an admin-only listing of recent
# searches on the site.
class SearchesController < ApplicationController
  # make search form work even from static 404 pages etc
  # (which don't have an authenticity token)
  skip_before_filter :verify_authenticity_token

  def create
    @offset = params[:offset].to_i
    @query   = params[:query] || ''
    @models = Needle.find_using_query_string @query,
                                             :offset => @offset,
                                             :user => current_user
  end
end
