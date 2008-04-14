# The whole point of the RestfulPaginator is to allow page-cacheable paginated resources
# so it doesn't support sort options (which would be incompatible with the caching).
class RestfulPaginator < Paginator
private
  def param_for_page page
    page > 1 ? "/#{page}" : ''
  end
end # class RestfulPaginator
