class ForumsController < ApplicationController
  before_filter :get_forum, :only => [ :show ]
  layout 'static'

  def index
    @forums = Forum.find_all
  end

  def show
    offset = 0
    limit = 10000
    @topics = Topic.find_topics_for_forum @forum, offset, limit
  end

private

  def public_only?
    !admin?
  end

  def get_forum
    if public_only?
      @forum = Forum.published.find_with_param! params[:id]
    else
      @forum = Forum.find_with_param! params[:id]
    end
  end

  def record_not_found
    super forums_path
  end
end
