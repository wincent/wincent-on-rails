class TopicsController < ApplicationController
  before_filter :require_admin,   :except => [ :create, :new, :show ]
  before_filter :get_forum,       :except => [ :index ]
  before_filter :get_topic,       :only => [ :show ]
  after_filter  :cache_feed,      :only => [ :show ]
  cache_sweeper :topic_sweeper,   :only => [ :create, :update, :destroy ]

  # Admin only.
  # The admin is allowed to see all unmoderated topics at once, for the purposes of moderation.
  def index
    @topics = Topic.find :all, :conditions => { :awaiting_moderation => true }
  end

  def new
    @topic = Topic.new
  end

  def create
    # TODO: tagging support (admin sees tag fields in the UI, but they have no effect yet)
    respond_to do |format|
      format.html {
        @topic = @forum.topics.build(params[:topic])
        @topic.user = current_user
        @topic.awaiting_moderation = !(admin? or logged_in_and_verified?)
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

  # Admin only for now.
  def update
    topic = @forum.topics.find(params[:id])
    respond_to do |format|
      format.html { raise 'not yet implemented' }
      format.js {
        if params[:button] == 'spam'
          topic.moderate_as_spam!
          render :update do |page|
            page.visual_effect :fade, "topic_#{topic.id}"
          end
        elsif params[:button] == 'ham'
          topic.moderate_as_ham!
          render :update do |page|
            page.visual_effect :highlight, "topic_#{topic.id}", :duration => 1.5
            page.visual_effect :fade, "topic_#{topic.id}_ham_form"
            page.visual_effect :fade, "topic_#{topic.id}_spam_form"
          end
        else
          raise 'unrecognized AJAX action'
        end
      }
    end
  end

  # Admin only.
  def destroy
    # TODO: mark topics as deleted_at rather than really destroying them
    topic = @forum.topics.find(params[:id])
    topic.destroy
    respond_to do |format|
      format.html { redirect_to forum_path(@forum) }
      format.js {
        render :update do |page|
          page.visual_effect :fade, "topic_#{topic.id}"
        end
      }
    end
  end

private

  def public_only?
    is_atom? || !admin?
  end

  def get_forum
    if public_only?
      @forum = Forum.find_with_param! params[:forum_id], :public => true
    else
      @forum = Forum.find_with_param! params[:forum_id]
    end
  end

  def get_topic
    if public_only?
      @topic = @forum.topics.find params[:id], :conditions => { :public => true, :awaiting_moderation => false }
    else
      @topic = @forum.topics.find params[:id], :conditions => { :awaiting_moderation => false }
    end
  end

  def record_not_found
    super @forum ? forum_path(@forum) : forums_path
  end
end
