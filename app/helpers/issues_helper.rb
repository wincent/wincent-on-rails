module IssuesHelper
  def scope_info
    scopes = []
    scopes << "product: #{h(params[:product])}" if params[:product]
    scopes << "kind: #{h(params[:kind].pluralize)}" if params[:kind]
    scopes << "status: #{h(params[:status])}" if params[:status]
    "Currently showing only issues with #{scopes.join(', ')}" unless scopes.empty?
  end

  def link_to_prev_issue
    link_to '&laquo; previous', issue_path(@prev), :title => "#{@prev.kind_string} \##{@prev.id}: #{@prev.summary}"
  end

  def link_to_next_issue
    link_to 'next &raquo;', issue_path(@next), :title => "#{@next.kind_string} \##{@next.id}: #{@next.summary}"
  end

  def link_to_product_issues product
    if product
      link_to(product.name, issues_path(:product => product.name))
    else
      'no product'
    end
  end

  def link_to_issue_search link_text = 'search'
    # TODO: make this unobtrusive, make it degrade gracefully
    link_to_function link_text,
      "$('#issue_search').toggle(); $('#issue_summary').focus()",
      :href => search_issues_path
  end
end
