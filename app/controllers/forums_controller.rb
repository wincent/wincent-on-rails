class ForumsController < ApplicationController
  before_filter :require_admin, :except => [ :show, :index ]
  before_filter :get_forum, :only => [ :show, :edit, :update ]
  uses_stylesheet_links

  def new
    @forum = Forum.new
  end

  def create
    @forum = Forum.new params[:forum]
    if @forum.save
      flash[:notice] = 'Successfully created new forum'
      redirect_to @forum
    else
      flash[:error] = 'Failed to create new forum'
      render :action => 'new'
    end
  end

  def index
    @forums = Forum.find_all
  end

  def show
    # for now we exclude topics awaiting moderation, could potentially include them and show them only to the admin
    @paginator = Paginator.new params, @forum.topics.count(:conditions => { :public => true, :awaiting_moderation => false }),
      forum_path(@forum), 20
    @topics = Topic.find_topics_for_forum @forum, @paginator.offset, @paginator.limit
  end

  # admin only
  def edit
    render
  end

  # admin only
  def update
    if @forum.update_attributes params[:forum]
      flash[:notice] = 'Successfully updated'
      redirect_to @forum
    else
      flash[:error] = 'Update failed'
      render :action => :edit
    end
  end

private

  def public_only?
    !admin?
  end

  def get_forum
    if public_only?
      @forum = Forum.find_with_param! params[:id], :public => true
    else
      @forum = Forum.find_with_param! params[:id]
    end
  end

  def record_not_found
    super forums_path
  end
end
