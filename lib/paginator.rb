class Paginator
  attr_reader :offset

  def initialize params, count, path
    # unpack params
    @params           = params
    page              = params[:page].to_i

    # preserve sort information in links
    @additonal_params = ''
    @additonal_params << "&sort=#{params[:sort]}" if params[:sort]
    @additonal_params << "&order=#{params[:order]}" if params[:order]

    # process page, count and path
    @page   = page > 0 ? page : 1
    @offset = (@page - 1) * 10
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

  def on_first_page?
    @offset == 0
  end

  def on_last_page?
    @offset >= @count - 10
  end

  def upper_offset
    upper_limit = @offset + 10
    upper_limit > @count ? @count : upper_limit
  end

  def label_text
    "Displaying #{@offset}-#{upper_offset} of #{@count}:"
  end

  def first_link
    if on_first_page?
      %Q{<span class="first disabled">First</span>}
    else
      %Q{<a href="#{@path}?page=1#{@additonal_params}" class="first">First</a>}
    end
  end

  def last_link
    if on_last_page?
      %Q{<span class="last disabled">Last</span>}
    else
      %Q{<a href="#{@path}?page=#{(@count / 10.0).ceil}#{@additonal_params}" class="last">Last</a>}
    end
  end

  def prev_link
    if on_first_page?
      %Q{<span class="prev disabled">Previous</span>}
    else
      %Q{<a href="#{@path}?page=#{@page - 1}#{@additonal_params}" class="prev">Previous</a>}
    end
  end

  def next_link
    if on_last_page?
      %Q{<span class="next disabled">Next</span>}
    else
      %Q{<a href="#{@path}?page=#{@page + 1}#{@additonal_params}" class="next">Next</a>}
    end
  end
end # class Paginator
