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
    # default catch-all routes aren't enabled
    # so path should already be sanitized by now
    "js/#{params[:delegated]}.js.erb"
  end
end
