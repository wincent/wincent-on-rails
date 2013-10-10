class Paginator
  # attributes of interest to models (for constructing "find" methods)
  attr_reader :offset, :limit

  # attributes of interest to specs (for confirming paginator configuration)
  attr_reader :count, :path_or_url

  def initialize params, count, path_or_url, per_page = 10
    # unpack params
    page = params[:page].to_i

    # preserve query-string information in links
    @additional_params = []
    params.each do |key, value|
      # we exclude protocol here to keep the URLs pretty
      # if you want your protocol preserved, pass in a URL rather than a path
      next if %w[action authenticity_token controller page protocol].include? key
      @additional_params << { key => value }.to_query
    end

    # process page, count and path_or_url
    @limit        = per_page
    @page         = page > 0 ? page : 1
    @offset       = (@page - 1) * @limit
    @count        = count
    @path_or_url  = path_or_url

    raise ActiveRecord::RecordNotFound if @offset > @count
  end

  # Displaying x-y of z | << First | < Previous | Next > | Last >>
  def pagination_links
    # don't bother trying to use safe_concat here; too much hoop-jumping
    items = [label_text, first_link, prev_link, next_link, last_link]
    content_tag :ul, items.join.html_safe, class: 'pagination'
  end

private

  # speaking of hoop-jumping, all this is to avoid building HTML using dumb
  # string concatenation
  include ActionView::Context               # for block-capturing
  include ActionView::Helpers::NumberHelper # for #number_with_delimiter
  include ActionView::Helpers::TagHelper    # for #content_tag
  include ActionView::Helpers::TextHelper   # for #safe_concat
  include ActionView::Helpers::UrlHelper    # for #link_to

  def params_for_page page
    params = @additional_params.clone
    params.unshift "page=#{page}" if page > 1
    params = params.join('&').gsub('&', '&amp;')
    params.empty? ? '' : "?#{params}"
  end

  def on_first_page?
    @offset == 0
  end

  def on_last_page?
    @offset >= @count - @limit
  end

  def upper_offset
    upper_limit = @offset + @limit
    upper_limit > @count ? @count : upper_limit
  end

  def label_text
    upper = upper_offset
    lower = @offset < upper ? @offset + 1 : @offset # @offset is zero-based, so adjust up by 1 if we can
    label = 'Displaying %s-%s of %s:' % [lower, upper, count].map { |n| number_with_delimiter(n) }
    content_tag :li, label
  end

  def first_link
    content_tag :li, class: ('disabled' if on_first_page?) do
      link_text, klass = 'First', 'first'
      if on_first_page?
        content_tag :span, link_text, class: klass
      else
        link_to link_text, "#{@path_or_url}#{params_for_page 1}", class: klass
      end
    end
  end

  # This and method and its counterpart use rel="prev"/rel="next" as advised by
  # Google here:
  #
  #   http://googlewebmastercentral.blogspot.com/2011/09/pagination-with-relnext-and-relprev.html
  def prev_link
    content_tag :li, class: ('disabled' if on_first_page?) do
      link_text, klass = 'Previous', 'prev icon-rotate-180' # for Font Awesome
      if on_first_page?
        content_tag :span, link_text, class: klass
      else
        link_to link_text, "#{@path_or_url}#{params_for_page(@page - 1)}",
          rel: 'prev',
          class: klass
      end
    end
  end

  def next_link
    content_tag :li, class: ('disabled' if on_last_page?) do
      link_text, klass = 'Next', 'next'
      if on_last_page?
        content_tag :span, link_text, class: klass
      else
        link_to link_text, "#{@path_or_url}#{params_for_page(@page + 1)}",
          rel: 'next',
          class: klass
      end
    end
  end

  def last_link
    content_tag :li, class: ('disabled' if on_last_page?) do
      link_text, klass = 'Last', 'last'
      if on_last_page?
        content_tag :span, link_text, class: klass
      else
        link_to link_text, "#{@path_or_url}#{params_for_page (@count / @limit.to_f).ceil}",
          class: klass
      end
    end
  end
end # class Paginator
