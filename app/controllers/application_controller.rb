class ApplicationController < ActionController::Base
  filter_parameter_logging  'passphrase'
  before_filter             :login_before
  after_filter              :cache_flash
  protect_from_forgery
  rescue_from               ActiveRecord::RecordNotFound, :with => :record_not_found

  # fix feed breakage caused by Rails 2.3.0 RC1
  # see: https://wincent.com/issues/1227
  layout Proc.new { |controller| controller.send(:is_atom?) ? false : 'application' }

protected

  # URL to the comment nested in the context of its parent (resources), including an anchor.
  # NOTE: this method is dog slow if called in an "N + 1 SELECT" situation
  def nested_comment_path comment
    commentable = comment.commentable
    anchor      = "comment_#{comment.id}"
    case commentable
    when Article, Issue, Post, Tweet
      send "#{commentable.class.to_s.downcase}_path", commentable, :anchor => anchor
    when Topic
      forum_topic_path commentable.forum, commentable, :anchor => anchor
    end
  end

  # TODO: make a special 404 action that provides hints for where people could look
  def record_not_found(uri = nil)
    if request.xhr?
      render :text => 'Requested record not found', :status => 404
    elsif is_atom?
      render :text => '', :status => 404
    else # HTML requests
      if uri.class != String
        # beware that in the default case uri will be an instance of ActiveRecord::RecordNotFound
        uri = root_path
      end
      flash[:error] = 'Requested %s not found' % controller_name.singularize
      redirect_to uri
    end
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

  # if the flash contains multiple items, turns it into an unordered list
  def listify_flash flashes
    return flashes unless flashes.kind_of?(Array)
    if flashes.empty?
      ''
    elsif flashes.length == 1
      flashes.first
    else
      items = flashes.map { |i| "<li>#{i}</li>" }
      "<ul>#{items.join}</ul>"
    end
  end

  def cache_flash
    flash_hash = {}
    flash.each do |key, value|
      flash_hash[key.to_sym] = listify_flash(value)
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
