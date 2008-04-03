class TopicsController < ApplicationController
  before_filter :get_forum
  before_filter :get_topic, :only => [ :show ]
  after_filter  :cache_show_feed, :only => :show
  cache_sweeper :topic_sweeper, :only => [ :create, :update, :destroy ]

  def new
    @topic = Topic.new
  end

  def create
    respond_to do |format|
      format.html {
        @topic = @forum.topics.build(params[:topic])
        @topic.user = current_user
        @topic.awaiting_moderation = (!admin? or !logged_in_and_verified?)
        if @topic.save
          if logged_in_and_verified?
            flash[:notice] = 'Successfully created new topic.'
            redirect_to forum_topic_path(@forum, @topic)
          else
            flash[:notice] = 'Successfully submitted topic (awaiting moderation).'
            redirect_to forum_path(@forum)
          end
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
    @comments = @topic.visible_comments # public, not awaiting moderation, not spam
    respond_to do |format|
      format.html {
        @topic.hit!
        @comment = @topic.comments.build if @topic.accepts_comments?
      }
      format.atom
    end
  end

private

  def get_forum
    # TODO: handle private forums?
    @forum = Forum.find_with_param! params[:forum_id]
  end

  def get_topic
    # TODO: handle private topics
    @topic = @forum.topics.find params[:id], :conditions => { :public => true, :awaiting_moderation => false }
  end

  def cache_show_feed
    cache_page if params[:format] == 'atom'
  end

  def record_not_found
    super @forum ? forum_path(@forum) : forums_path
  end
end
