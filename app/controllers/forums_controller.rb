class ForumsController < ApplicationController
  before_filter :get_forum, :only => [ :show ]


  def index
    @forums = Forum.find_all
  end

  def show
    # for now we exclude topics awaiting moderation, could potentially include them and show them only to the admin
    @paginator = Paginator.new params, @forum.topics.count(:conditions => { :public => true, :awaiting_moderation => false }),
      forum_path(@forum), 20
    @topics = Topic.find_topics_for_forum @forum, @paginator.offset, @paginator.limit
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
