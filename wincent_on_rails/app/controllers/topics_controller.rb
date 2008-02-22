class TopicsController < ApplicationController
  before_filter :get_forum
  before_filter :get_topic, :only => [ :show ]

  def new
    @topic = Topic.new
  end

  def create
    respond_to do |format|
      format.html {
        @topic = @forum.topics.build(params[:topic])
        @topic.user = current_user
        @topic.awaiting_moderation = true unless logged_in?
        if @topic.save
          flash[:notice] = 'Successfully created new topic.'
          redirect_to forum_topic_path(@forum, @topic)
        else
          flash[:error] = 'Failed to create new topic.'
          render :action => 'new'
        end
      }

      # this is the AJAX preview
      format.js {
        @title    = params[:title]   || ''
        @excerpt  = params[:excerpt] || ''
        render :partial => 'preview'
      }
    end
  end

  def show
    @topic.hit!
  end

private

  def get_forum
    @forum = Forum.find_with_param params[:forum_id]
  end

  def get_topic
    @topic = @forum.topics.find(params[:id], :include => 'comments')
  end

end
