class JsController < ApplicationController
  # need this or JavaScript will get embedded in default application layout (HTML)
  layout false

  def show
    respond_to do |format|
      format.js { render template_path_from_params }
    end
  end

private

  def template_path_from_params
    # can't leave sanitization up to routing because attacker could still get
    # here via default catch-all routes
    delegated = params[:delegated].split('/')
    raise ArgumentError unless delegated.length >= 2
    raise ArgumentError unless delegated.all? do |component|
      component =~ %r{\A[a-z_]+\z}
    end
    "js/#{delegated.join('/')}.js.erb"
  end
end
