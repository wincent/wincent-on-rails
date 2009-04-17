module IssuesHelper
  def scope_info
    scopes = []
    scopes << "product: #{h(params[:product])}" if params[:product]
    scopes << "kind: #{h(params[:kind].pluralize)}" if params[:kind]
    scopes << "status: #{h(params[:status])}" if params[:status]
    "Currently showing only issues with #{scopes.join(', ')}" unless scopes.empty?
  end

  def js_for_attribute attribute, value_accessor
    remote_function \
      :update   => attribute.to_sym,
      :url      => { :action => "update_#{attribute.to_s}".to_sym, :id => @issue.id },
      :with     => "'#{attribute.to_s}=' + $('issue_#{attribute.to_s}').#{value_accessor.to_s}",
      :before   => "Element.show('#{attribute.to_s}_spinner')",
      :complete => "Element.hide('#{attribute.to_s}_spinner')",
      :failure  => "alert('HTTP Error ' + request.status)"
  end

  def link_to_prev_issue
    link_to '&laquo; previous', issue_url(@prev), :title => "#{@prev.kind_string} \##{@prev.id}: #{@prev.summary}"
  end

  def link_to_next_issue
    link_to 'next &raquo;', issue_url(@next), :title => "#{@next.kind_string} \##{@next.id}: #{@next.summary}"
  end

  def link_to_product_issues product
    if product
      link_to(product.name, issues_url(:product => product.name))
    else
      'no product'
    end
  end

  def link_to_issue_search link_text = 'search'
    # TODO: make this unobtrusive, make it degrade gracefully
    link_to_function link_text,
      "jQuery('#issue_search').toggle(); jQuery('#issue_summary').focus()",
      :href => search_issues_url
  end
end
