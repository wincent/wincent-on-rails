module IssuesHelper
  def scope_info
    scopes = []
    if params[:product]
      scopes << "product: #{h(params[:product])}"
    end
    if params[:kind]
      scopes << "kind: #{h(params[:kind].pluralize)}"
    end
    if params[:status]
      scopes << "status: #{h(params[:status])}"
    end
    "Currently showing only issues with #{scopes.join(', ')}" unless scopes.empty?
  end
end
