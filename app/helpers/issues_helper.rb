module IssuesHelper
  def scope_info
    scopes = []
    scopes << "product: #{h(params[:product])}" if params[:product]
    scopes << "kind: #{h(params[:kind].pluralize)}" if params[:kind]
    scopes << "status: #{h(params[:status])}" if params[:status]
    "Currently showing only issues with #{scopes.join(', ')}" unless scopes.empty?
  end

  # Convert key names from "feature_request" etc to "feature request"
  def underscores_to_spaces options
    options.collect { |k,v| [k.to_s.gsub('_', ' '), v] }
  end

  def product_options
    Product.find(:all).collect { |product| [product.name, product.id] }
  end

  def ajax_select form, attribute, options, extra_options = {}
    popup   = form.select attribute, options, extra_options, :onchange => js_for_attribute(attribute, :value)
    spinner = spinner_for_attribute attribute
    "#{popup}&nbsp;#{spinner}"
  end

  def ajax_check_box form, attribute
    box     = form.check_box attribute, :onchange => js_for_attribute(attribute, :checked)
    spinner = spinner_for_attribute attribute
    "#{box}&nbsp;#{spinner}"
  end

  def spinner_for_attribute attribute
    image_tag 'spinner.gif', :id => "#{attribute.to_s}_spinner", :style => 'display:none;'
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
end
