# The whole point of the RestfulPaginator is to allow page-cacheable paginated resources
# so it doesn't support sort options (which would be incompatible with the caching).
class RestfulPaginator < Paginator
private

  # beware if using RestfulPaginator in order to get page-cacheable paginated resources:
  # additional params (like sort options) will be passed through but have no effect
  def params_for_page page
    page_string = page > 1 ? "/page/#{page}" : ''
    params = @additional_params.join('&')
    if params.empty?
      page_string
    else
      page_string + "?#{params}"
    end
  end
end # class RestfulPaginator
