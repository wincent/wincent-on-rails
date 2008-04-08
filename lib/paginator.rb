class Paginator
  attr_reader :offset, :limit

  def initialize params, count, path, per_page = 10
    # unpack params
    page              = params[:page].to_i

    # preserve query-string information in links
    @additional_params = []
    params.each do |key, value|
      next if ['page', 'action', 'controller'].include? key
      @additional_params << "#{key.to_s}=#{value.gsub(' ', '+')}" # if we let through spaces they become %20, which is ugly
    end

    # process page, count and path
    @limit  = per_page
    @page   = page > 0 ? page : 1
    @offset = (@page - 1) * @limit
    @count  = count
    @path   = path
    if @offset > @count
      @offset = 0
      @page   = 1
    end
  end

  # Displaying x-y of z | << First | < Previous | Next > | Last >>
  def pagination_links
    [label_text, first_link, prev_link, next_link, last_link].join " | "
  end

private
  include ActionView::Helpers::NumberHelper # for number_with_delimiter

  def params_for_page page
    params = @additional_params.clone
    params.unshift "page=#{page}" if page > 1
    params.length > 0 ? "?#{params.join('&')}" : ''
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
    "Displaying #{number_with_delimiter(lower)}-#{number_with_delimiter(upper)} of #{number_with_delimiter(@count)}:"
  end

  def first_link
    if on_first_page?
      %Q{<span class="first disabled">First</span>}
    else
      %Q{<a href="#{@path}#{params_for_page(1)}" class="first">First</a>}
    end
  end

  def last_link
    if on_last_page?
      %Q{<span class="last disabled">Last</span>}
    else
      %Q{<a href="#{@path}#{params_for_page((@count / @limit.to_f).ceil)}" class="last">Last</a>}
    end
  end

  def prev_link
    if on_first_page?
      %Q{<span class="prev disabled">Previous</span>}
    else
      %Q{<a href="#{@path}#{params_for_page(@page - 1)}" class="prev">Previous</a>}
    end
  end

  def next_link
    if on_last_page?
      %Q{<span class="next disabled">Next</span>}
    else
      %Q{<a href="#{@path}#{params_for_page(@page + 1)}" class="next">Next</a>}
    end
  end
end # class Paginator
