class TopicsController < ApplicationController
  before_filter :require_admin,   :except => [ :create, :new, :show ]
  before_filter :get_forum,       :except => [ :index ]
  before_filter :get_topic,       :only => [ :show ]
  caches_page   :show,            :if => Proc.new { |c| c.send(:is_atom?) }
  cache_sweeper :topic_sweeper,   :only => [ :create, :update, :destroy ]
  uses_stylesheet_links

  # Admin only.
  # The admin is allowed to see all unmoderated topics at once, for the purposes of moderation.
  def index
    @topics = Topic.where :awaiting_moderation => true
  end

  def new
    @topic = Topic.new
  end

  def create
    # TODO: tagging support (admin sees tag fields in the UI, but they have no effect yet)
    if request.xhr? # live preview
      # TODO: hook up live preview in templates
      @title    = params[:title]   || ''
      @excerpt  = params[:excerpt] || ''
      render :partial => 'preview'
    else # normal request
      @topic = @forum.topics.build(params[:topic])
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
        @comment = @topic.comments.build if @topic.accepts_comments?
      }
      format.atom
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
        @topic.accepts_comments = params[:topic][:accepts_comments]
        @topic.public           = params[:topic][:public]
        if @topic.update_attributes params[:topic]
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
          raise 'unrecognized AJAX action'
        end
      }
    end
  end

  # Admin only.
  def destroy
    # TODO: mark topics as deleted_at rather than really destroying them
    topic = @forum.topics.find params[:id]
    topic.destroy
    respond_to do |format|
      format.html { redirect_to @forum }
      format.js   { render :json => {}.to_json }
    end
  end

private

  def public_only?
    is_atom? || !admin?
  end

  def get_forum
    if params[:forum_id]
      if public_only?
        @forum = Forum.find_with_param! params[:forum_id], :public => true
      else
        @forum = Forum.find_with_param! params[:forum_id]
      end
    else # special case for topic links without forum in params (helps us avoid some "N + 1 SELECT" problems)
      topic = Topic.includes(:forum).find params[:id]
      redirect_to forum_topic_path(topic.forum, topic)
    end
  end

  def get_topic
    if public_only?
      @topic = @forum.topics.
        where(:public => true, :awaiting_moderation => false).find params[:id]
    else
      @topic = @forum.topics.
        where(:awaiting_moderation => false).find params[:id]
    end
  end

  def record_not_found
    super @forum ? forum_path(@forum) : forums_path
  end
end
