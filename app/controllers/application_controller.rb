class ApplicationController < ActionController::Base
  filter_parameter_logging  'passphrase'
  before_filter             :ensure_correct_protocol, :login_before
  after_filter              :cache_flash
  protect_from_forgery
  rescue_from               ActiveRecord::RecordNotFound, :with => :record_not_found

  # fix feed breakage caused by Rails 2.3.0 RC1
  # see: https://wincent.com/issues/1227
  layout Proc.new { |controller| controller.send(:is_atom?) ? false : 'application' }

protected

  # For use in admin actions.
  def set_protected_attribute attribute, model_instance, params_hash
    if params_hash and params_hash.has_key?(attribute)
      model_instance.send("#{attribute}=", params_hash[attribute])
      params_hash[attribute] = nil
    end
  end

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

  # TODO: make a special 404 action that provides hints for where people could look
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
      nil # find everything
    elsif logged_in?
      "public = TRUE OR user_id = #{current_user.id}"
    else
      'public = TRUE'
    end
  end

  def default_access_options
    if conditions = default_access_options_including_awaiting_moderation
      'awaiting_moderation = FALSE AND ' + conditions
    else
      'awaiting_moderation = FALSE'
    end
  end

  # nginx will rewrite HTTP URLs to HTTPs automatically
  # but still need to catch improper direct access to the mongrels
  # (if somebody guesses their port numbers, they can connect via HTTP)
  def ensure_correct_protocol
    if not request.ssl?
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

  def cache_flash
    flash_hash = {}
    flash.each do |key, value|
      flash_hash[key.to_sym] = value
    end

    # without this we'll get double-flashes for "render" followed by another page view
    flash.clear

    # always leave cookie flash deletion up to the browser
    cookies[:flash] = flash_hash.to_json unless flash_hash.blank?
  end

  # uncomment this method to test what remote users will see
  # when there are errors (must be in production mode)
  #def local_request?
  #  false
  #end
end
