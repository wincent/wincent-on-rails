module IssuesHelper
  def scope_info
    scopes = []
    scopes << "product: #{params[:product]}" if params[:product]
    scopes << "kind: #{params[:kind].pluralize}" if params[:kind]
    scopes << "status: #{params[:status]}" if params[:status]
    "Currently showing only issues with #{scopes.join(', ')}" unless scopes.empty?
  end

  def issue_tooltip issue
    "#{issue.kind_string} \##{issue.id}: #{issue.summary}"
  end

  def link_to_prev_issue issue
    if issue
      link_to '&laquo; previous'.html_safe, issue_path(issue),
        :title => issue_tooltip(issue)
    end
  end

  def link_to_next_issue issue
    if issue
      link_to 'next &raquo;'.html_safe, issue_path(issue),
        :title => issue_tooltip(issue)
    end
  end

  def link_to_product_issues product
    if product
      link_to product.name, issues_path(:product => product.name)
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

  def kind_options_for_select
    underscores_to_spaces(Issue::KIND).sort
  end

  def status_options_for_select
    underscores_to_spaces(Issue::STATUS).sort
  end
end
