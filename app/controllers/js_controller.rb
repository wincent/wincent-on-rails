class JsController < ApplicationController
  before_filter :get_template_path_from_params

  def show
    respond_to do |format|
      format.js {
        if (Rails.root + 'app' + 'views' + @template).exist?
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
end
