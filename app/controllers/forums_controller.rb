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
    # TODO: sort by something less arbitary than forums.id (admin-settable sort order would be nice)
    @forums = Forum.find_by_sql <<-SQL
      SELECT forums.id, forums.name, forums.description, forums.topics_count,
             MAX(topics.updated_at) AS last_active_at, topics.id AS last_topic_id
      FROM forums
      JOIN topics WHERE forums.id = topics.forum_id
      GROUP BY topics.forum_id
      ORDER BY forums.id
    SQL
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
    #@topics = @forum.topics.find(:all, :conditions => { :public => true }, :limit => @paginator.limit,
    #  :offset => @paginator.offset, :include => ['user', 'last_commenter'])

    # option 4: custom SQL, one LEFT OUTER JOIN and only pulls in only the columns required
    sql = <<-SQL
      SELECT topics.id, topics.title, topics.comments_count, topics.view_count, topics.updated_at, topics.last_comment_id,
             users.id AS last_active_user_id,
             users.display_name AS last_active_user_display_name
      FROM topics
      LEFT OUTER JOIN users ON (users.id = IFNULL(topics.last_commenter_id, topics.user_id))
      WHERE topics.forum_id = ? AND public = ?
      ORDER BY topics.updated_at DESC
      LIMIT ?, ?
    SQL
    @topics = Topic.find_by_sql [sql, @forum.id, true, @paginator.offset, @paginator.limit]
  end

private

  def get_forum
    @forum = Forum.find_with_param params[:id]
  end

  def record_not_found
    super forums_path
  end

end
