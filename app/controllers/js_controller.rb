class JsController < ApplicationController
  before_filter :get_template_path_from_params

  # don't embed JS in default application layout (HTML)
  layout false

  def show
    respond_to do |format|
      format.js {
        if template_exists?
          render @template
        else
          render :text => '', :status => 404
        end
      }
    end
  end

private

  def get_template_path_from_params
    # no need to sanitize as router ensures param is of format:
    #   ([a-z_]+/)+[a-z_]+\.js
    @template = "js/#{params[:delegated]}.erb"
  end

  def template_exists?
    (Rails.root + 'app' + 'views' + @template).exist?
  end
end
