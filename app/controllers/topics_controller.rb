class TopicsController < ApplicationController
  before_filter :require_admin, except: %i[create new show]
  before_filter :get_forum,     except: %i[destroy index]
  before_filter :get_topic,     only: :show

  # Admin only.
  # The admin is allowed to see all unmoderated topics at once, for the purposes of moderation.
  def index
    @topics = Topic.where awaiting_moderation: true
  end

  def new
    @topic = Topic.new
  end

  def create
    if request.xhr? # live preview
      # TODO: hook up live preview in templates
      @title    = params[:title]   || ''
      @excerpt  = params[:excerpt] || ''
      render :partial => 'preview'
    else # normal request
      @topic = @forum.topics.new(topic_params)
      @topic.user = current_user
      @topic.awaiting_moderation = !(admin? or logged_in_and_verified?)
      if @topic.save
        if logged_in_and_verified?
          flash[:notice] = 'Successfully created new topic'
          redirect_to forum_topic_path(@forum, @topic)
        else
          flash[:notice] = 'Successfully submitted topic (awaiting moderation)'
          redirect_to @forum
        end
      else
        flash[:error] = 'Failed to create new topic'
        render :action => 'new'
      end
    end
  end

  def show
    @comments = @topic.comments.published # public, not awaiting moderation
    respond_to do |format|
      format.html {
        @topic.hit!
        @comment = @topic.comments.new if @topic.accepts_comments?
      }
    end
  end

  # Admin only for now.
  def edit
    @topic = @forum.topics.find params[:id] # no restrictions
  end

  # Admin only for now.
  def update
    @topic = @forum.topics.find params[:id] # no restrictions
    respond_to do |format|
      format.html {
        if @topic.update_attributes topic_params
          flash[:notice] = 'Successfully updated'
          redirect_to forum_topic_path(@forum, @topic)
        else
          flash[:error] = 'Update failed'
          render :action => 'edit'
        end
      }
      format.js {
        if params[:button] == 'ham'
          @topic.moderate_as_ham!
          render :json => {}.to_json
        else
          raise 'unrecognized Ajax action'
        end
      }
    end
  end

  # Admin only.
  def destroy
    # TODO: mark topics as deleted_at rather than really destroying them
    @topic = Topic.find params[:id] # shallow route
    @topic.destroy
    respond_to do |format|
      format.html {
        flash[:notice] = 'Topic destroyed'
        redirect_to @topic.forum
      }
      format.js
    end
  end

private

  def topic_params
    permitted = %i[title body]
    permitted.concat(%i[pending_tags public accepts_comemnts]) if admin?
    params.require(:topic).permit(*permitted)
  end

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
