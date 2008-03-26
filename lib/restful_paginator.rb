# The whole point of the RestfulPaginator is to allow page-cacheable paginated resources
# so it doesn't support sort options (which would be incompatible with the caching).
class RestfulPaginator < Paginator
  def initialize params, count, path, per_page = 10
    super
    @additional_params = ''
  end

private

  def param_for_page page
    page > 1 ? "/#{page}" : ''
  end
end # class RestfulPaginator
