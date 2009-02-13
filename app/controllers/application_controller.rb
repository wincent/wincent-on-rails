class ApplicationController < ActionController::Base
  #helper                    :all # include all helpers, all the time
  filter_parameter_logging  'passphrase'
  before_filter             :ensure_correct_protocol, :login_before
  protect_from_forgery
  rescue_from               ActiveRecord::RecordNotFound, :with => :record_not_found

protected

  # URL to the comment nested in the context of its parent (resources), including an anchor.
  # NOTE: this method is dog slow if called in an "N + 1 SELECT" situation
  def nested_comment_url comment
    commentable = comment.commentable
    anchor      = "comment_#{comment.id}"
    case commentable
    when Article, Issue, Post
      send "#{commentable.class.to_s.downcase}_url", commentable, :anchor => anchor
    when Topic
      forum_topic_url commentable.forum, commentable, :anchor => anchor
    end
  end

  def record_not_found(uri = nil)
    if uri.class != String
      # beware that in the default case uri will be an instance of ActiveRecord::RecordNotFound
      uri = root_url
    end
    flash[:error] = 'Requested %s not found' % controller_name.singularize
    redirect_to uri
  end

  def is_atom?
    params[:format] == 'atom'
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

  # nginx will rewrite HTTP URLs to HTTPs automatically
  # but still need to catch improper direct access to the mongrels
  # (if somebody guesses their port numbers, they can connect via HTTP)
  def ensure_correct_protocol
    # horrible kludge (runtime test for test environment)
    # see: http://rubyforge.org/pipermail/rspec-users/2009-February/012347.html
    if not request.ssl? and ENV['RAILS_ENV'] != 'test'
      url = 'https://' + request.host
      url << ":#{APP_CONFIG['port']}" if APP_CONFIG['port'] != 443
      url << request.request_uri
      redirect_to url
      flash.keep
      false
    else
      true
    end
  end

  # uncomment this method to test what remote users will see when there are errors in production mode
  # def local_request?
  #   false
  # end
end
