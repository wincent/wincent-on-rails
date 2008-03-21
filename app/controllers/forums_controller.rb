class ForumsController < ApplicationController
  before_filter :require_admin, :except => [ :show, :index ]
  before_filter :get_forum, :only => [ :show ]

  def new
    @forum = Forum.new
  end

  def create
    @forum = Forum.new(params[:forum])
    if @forum.save
      flash[:notice] = 'Successfully created new forum.'
      redirect_to forum_path(@forum)
    else
      flash[:error] = 'Failed to create new forum.'
      render :action => 'new'
    end
  end

  def index
    @forums = Forum.find(:all)
  end

  def show
    @paginator = Paginator.new(params, @forum.topics.count(:conditions => { :public => true }), forum_path(@forum), 20)
    @topics = @forum.topics.find(:all, :conditions => { :public => true }, :limit => @paginator.limit, :offset => @paginator.offset)
  end

private

  def get_forum
    @forum = Forum.find_with_param params[:id]
  end

  def record_not_found
    super forums_path
  end

end
