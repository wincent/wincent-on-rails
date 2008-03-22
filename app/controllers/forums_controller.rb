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

    # option 1: full "N + 1" SELECT problem caused when the view does topic.last_commenter.display_name on each topic
    #@topics = @forum.topics.find(:all, :conditions => { :public => true }, :limit => @paginator.limit,
    #  :offset => @paginator.offset)

    # option 2: "N + some": still incurring a topic.user.display_name query for each topic which doesn't have comments yet
    #@topics = @forum.topics.find(:all, :conditions => { :public => true }, :limit => @paginator.limit,
    #  :offset => @paginator.offset, :include => 'last_commenter')

    # option 3: "N + none": no extra queries, but two LEFT OUTER JOINS which make for a complex query
    @topics = @forum.topics.find(:all, :conditions => { :public => true }, :limit => @paginator.limit,
      :offset => @paginator.offset, :include => ['user', 'last_commenter'])
  end

private

  def get_forum
    @forum = Forum.find_with_param params[:id]
  end

  def record_not_found
    super forums_path
  end

end
