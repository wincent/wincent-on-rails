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

  # Previous | 1 | 2 | ... | 32 | 33 | 34 | 35 |[36]| Next
  # Previous |[1]| 2 | 3 | 4 | 5 | ... | 35 | 36 | Next
  # Previous | 1 | 2 | ... | 14 | 15 |[16]| 17 | 18 | ... | 35 | 36 | Next
  # Previous | 1 | 2 | ... | 5 | 6 |[7]| 8 | 9 | ... | 35 | 36 | Next
  # Previous | 1 | 2 | 3 | 4 | 5 |[6]| 7 | 8 | ... | 35 | 36 | Next
  def pagination_links
    # don't bother trying to use safe_concat here; too much hoop-jumping
    items = [prev_link] + numbered_links + [next_link]
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

  def numbered_links
    page_numbers = (1..last_page_number).to_a

    if @page <= last_page_number - 6
      # insert ellipsis between @page + 2 and 2-from-the-end
      page_numbers[(@page + 2)...-2] = nil
    end

    if @page > 6
      # insert ellipsis between "2" and @page - 2
      page_numbers[2...(@page - 3)] = nil
    end

    page_numbers.map do |number|
      if number.nil?
        item('&hellip;'.html_safe, class: 'disabled') # ellipsis
      elsif number == @page
        item(number, class: 'current')
      else
        item(number, target: "#{@path_or_url}#{params_for_page(number)}")
      end
    end
  end

  def item(text, options)
    content_tag :li, class: (options[:class] if options.has_key?(:class)) do
      if options.has_key?(:target)
        link_to text, options[:target]
      else
        content_tag :span, text
      end
    end
  end

  def params_for_page page
    params = @additional_params.clone
    params.unshift "page=#{page}" if page > 1
    params = params.join('&')
    params.empty? ? '' : "?#{params}"
  end

  def on_first_page?
    @offset == 0
  end

  def last_page_number
    (@count / @limit.to_f).ceil
  end

  def on_last_page?
    @page == last_page_number
  end

  # This and method and its counterpart use rel="prev"/rel="next" as advised by
  # Google here:
  #
  #   http://googlewebmastercentral.blogspot.com/2011/09/pagination-with-relnext-and-relprev.html
  def prev_link
    content_tag :li, class: ('disabled' if on_first_page?) do
      link_text, klass = 'Previous', 'prev'
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
end # class Paginator
