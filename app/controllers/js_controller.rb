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
    # can't leave sanitization up to routing because attacker could still get here via default catch-all routes
    delegating_controller = params[:delegating_controller]
    delegated_action = params[:delegated_action]
    unless delegating_controller =~ /\A[a-z_]+\z/ and delegated_action =~ /\A[a-z]+\z/
      raise ArgumentError
    end
    "js/#{delegating_controller}/#{delegated_action}.js.erb"
  end
end
