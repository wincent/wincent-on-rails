class TopicsController < ApplicationController
  before_filter :get_forum
  before_filter :get_topic
  layout 'static'

  def show
    @comments = @topic.comments.published # public, not awaiting moderation
    respond_to do |format|
      format.html {
        @topic.hit!
        @comment = @topic.comments.new if @topic.accepts_comments?
      }
    end
  end

private

  def public_only?
    !admin?
  end

  def get_forum
    if params[:forum_id]
      if public_only?
        @forum = Forum.published.find_with_param! params[:forum_id]
      else
        @forum = Forum.find_with_param! params[:forum_id]
      end
    else # special case for topic links without forum in params (helps us avoid some "N + 1 SELECT" problems)
      topic = Topic.includes(:forum).find params[:id]
      redirect_to forum_topic_path(topic.forum, topic)
    end
  end

  def get_topic
    @topic = if public_only?
      @forum.topics.where(public: true, awaiting_moderation: false)
    else
      @forum.topics.where(awaiting_moderation: false)
    end.find(params[:id])
  end

  def record_not_found
    super @forum ? forum_path(@forum) : forums_path
  end
end
