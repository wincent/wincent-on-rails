module IssuesHelper
  def scope_info
    scopes = []
    scopes << "product: #{h(params[:product])}" if params[:product]
    scopes << "kind: #{h(params[:kind].pluralize)}" if params[:kind]
    scopes << "status: #{h(params[:status])}" if params[:status]
    "Currently showing only issues with #{scopes.join(', ')}" unless scopes.empty?
  end

  def ajax_select form, attribute, options
    js = remote_function \
      :update   => attribute.to_sym,
      :url      => { :action => "update_#{attribute.to_s}".to_sym, :id => @issue.id },
      :with     => "'#{attribute.to_s}=' + $('issue_#{attribute.to_s}').value",
      :before   => "Element.show('#{attribute.to_s}_spinner')",
      :complete => "Element.hide('#{attribute.to_s}_spinner')",
      :failure  => "alert('HTTP Error ' + request.status)"
    form.select attribute, options, {}, :onchange => js
  end
end
