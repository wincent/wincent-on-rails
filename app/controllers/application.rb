class ApplicationController < ActionController::Base
  #helper                    :all # include all helpers, all the time
  filter_parameter_logging  'passphrase'
  before_filter             :login_before
  protect_from_forgery      :secret => APP_CONFIG['forgery_secret']
  rescue_from               ActiveRecord::RecordNotFound, :with => :record_not_found

  # all feeds are public, so turn off session management for them
  session :off,             :if => Proc.new { |req| req.format.atom? }

protected

  # URL to the comment nested in the context of its parent (resources), including an anchor.
  # NOTE: this method is dog slow if called in an "N + 1 SELECT" situation
  # this is needed in both controllers (for redirect_to) and views, hence the helper_method call here
  helper_method :polymorphic_comment_path
  def polymorphic_comment_path comment
    commentable     = comment.commentable
    common_options  = { :action => 'show', :id => commentable.to_param, :anchor => "comment_#{comment.id}"}
    case commentable
    when Article, Issue, Post
      url_for common_options.merge({:controller => commentable.class.to_s.tableize})
    when Topic
      forum_topic_path(commentable.forum, commentable) + "\#comment_#{comment.id}"
    end
  end

  # again, needed in controllers (redirect_to) and views
  helper_method :polymorphic_comments_path
  def polymorphic_comments_path comment
    # the case statement is a temporary hack until Rails 2.1 comes out
    # we can't do this dynamically for now because of irregularities in the route names
    # ie. articles have wiki paths instead of article paths
    # in 2.1 should be able to make them have article paths
    class_str = comment.commentable.class.to_s
    case class_str
    when 'Article'
      article = comment.commentable
      article_comment_path article, comment
    when 'Issue'
      issue = comment.commentable
      issue_comment_path issue, comment
    when 'Post'
      post = comment.commentable
      blog_comment_path post, comment
    when 'Topic'
      topic = comment.commentable
      forum = topic.forum
      forum_topic_comment_path forum, topic, comment
    end
  end

  def record_not_found(uri = nil)
    if uri.class != String
      # beware that in the default case uri will be an instance of ActiveRecord::RecordNotFound
      uri = root_path
    end
    flash[:error] = 'Requested %s not found' % controller_name.singularize
    redirect_to uri
  end

  def is_atom?
    params[:format] == 'atom'
  end

  # NOTE: as of Rails 2.1 this method will not longer be necessary
  # see: http://github.com/rails/rails/commit/14a40804a29a57ad05ca6bffbe1e5334089593a9
  # see: http://github.com/rails/rails/commit/7708650f73ddb4db300ea2059c60c1d907a4384e
  def cache_feed
    cache_page if is_atom?
  end

  # Just like the default_access_options method but this time we don't exclude items awaiting moderation.
  # This is useful in places like the issue tracker where we wish to show "this item is awaiting moderation"
  # rather than just do a "record not found".
  def default_access_options_including_awaiting_moderation
    if admin?
      'spam = FALSE'
    elsif logged_in?
      "spam = FALSE AND (public = TRUE OR user_id = #{current_user.id})"
    else
      'spam = FALSE AND public = TRUE'
    end
  end

  def default_access_options
    'awaiting_moderation = FALSE AND ' + default_access_options_including_awaiting_moderation
  end

  # uncomment this method to test what remote users will see when there are errors in production mode
  # def local_request?
  #   false
  # end
end
