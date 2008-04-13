class ApplicationController < ActionController::Base
  #helper                    :all # include all helpers, all the time
  filter_parameter_logging  'passphrase'
  before_filter             :login_before
  after_filter              :clear_redirection_info
  protect_from_forgery      :secret => '1b8b0816466a6f55b2a2a860c59d3ba0'
  rescue_from               ActiveRecord::RecordNotFound, :with => :record_not_found

  # all feeds are public, so turn off session management for them
  session :off,             :if => Proc.new { |req| req.format.atom? }

protected

  # URL to the comment nested in the context of its parent (resources), including an anchor.
  # NOTE: this method is dog slow if called in an "N + 1 SELECT" situation
  # this is needed in both controllers (for redirect_to) and views, hence the helper_method call here
  helper_method :url_for_comment
  def url_for_comment comment
    commentable     = comment.commentable
    common_options  = { :action => 'show', :id => commentable.to_param, :anchor => "comment_#{comment.id}"}
    case commentable
    when Article, Issue, Post
      url_for common_options.merge({:controller => commentable.class.to_s.tableize})
    when Topic
      forum_topic_path(commentable.forum, commentable) + "\#comment_#{comment.id}"
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

  # This method is needed because wiki articles can be redirections to any URL.
  # In the case were we redirect to another wiki article, the articles controller can handle
  # the clearing of the session, but when we redirect to another section of the site (the forums,
  # for instance) we need all other controllers to know how to clear the redirection info as well.
  # The articles controller itself overrides this filter as it is the only controller which requires
  # custom behaviour.
  def clear_redirection_info
    session[:redirected_from]   = nil
    session[:redirection_count] = 0
  end

  def default_access_options
    if admin?
      'awaiting_moderation = FALSE AND spam = FALSE'
    elsif logged_in?
      "awaiting_moderation = FALSE AND spam = FALSE AND (public = TRUE OR user_id = #{current_user.id})"
    else
      'awaiting_moderation = FALSE AND spam = FALSE AND public = TRUE'
    end
  end

  # uncomment this method to test what remote users will see when there are errors in production mode
  # def local_request?
  #   false
  # end
end
