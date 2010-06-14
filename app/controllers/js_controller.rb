class JsController < ApplicationController
  # don't embed JS in default application layout (HTML)
  layout false

  def show
    respond_to do |format|
      format.js { render template_path_from_params }
    end
  end

private

  def template_path_from_params
    # no need to sanitize as router ensures param is of format:
    #   ([a-z_]+/)+[a-z_]+\.js
    "js/#{params[:delegated]}.erb"
  end
end
