class Admin::ForumsController < Admin::ApplicationController
  before_filter :find_forum, only: [:show, :update]

  def index
    @forums = Forum.all
  end

  def show
    respond_to do |format|
      format.js do
        render json: @forum.to_json(only: %i[description name position])
      end
    end
  end

  def update
    respond_to do |format|
      format.js do
        if @forum.update_attributes params[:forum]
          # don't use admin_forum_path here because we want to force the use of a
          # numeric id; url_for will keep us in admin namespace here
          redirect_to url_for(controller: 'forums',
                              action: 'show',
                              id: @forum.id)
        else
          render text:   "Update failed: #{@forum.flashable_error_string}",
                 status: 422
        end
      end
    end
  end

private

  def find_forum
    @forum = Forum.find_with_param!(params[:id])
  end
end
