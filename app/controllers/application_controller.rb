class ApplicationController < ActionController::Base
  before_filter             :login_before
  after_filter              :cache_flash
  protect_from_forgery
  rescue_from               ActionController::ForbiddenError, :with => :forbidden
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

  def handle_http_status_code code, &block
    if request.xhr?
      render :text => Rack::Utils::HTTP_STATUS_CODES[code], :status => code
    elsif is_atom?
      render :text => '', :status => code
    else # HTML requests
      if block_given?
        yield
      else
        render :file => Rails.root + 'public' + "#{code}.html", :status => code,
          :layout => false
      end
    end
  end

  # 403 error: request understood by refused, and authentication will not help
  def forbidden
    handle_http_status_code 403
  end

  # TODO: make a special 404 action that provides hints for where people could look
  def record_not_found uri = nil
    handle_http_status_code 404 do
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
      nil # find everything
    elsif logged_in?
      # be careful with operator precendence
      # see: https://wincent.com/issues/1546
      "(public = TRUE OR user_id = #{current_user.id})"
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

  def rescue_action_in_public exception
    # From vendor/rails/actionpack/lib/action_controller/rescue.rb:
    #
    #  'ActionController::RoutingError'             => :not_found,
    #  'ActionController::UnknownAction'            => :not_found,
    #  'ActiveRecord::RecordNotFound'               => :not_found,
    #  'ActiveRecord::StaleObjectError'             => :conflict,
    #  'ActiveRecord::RecordInvalid'                => :unprocessable_entity,
    #  'ActiveRecord::RecordNotSaved'               => :unprocessable_entity,
    #  'ActionController::MethodNotAllowed'         => :method_not_allowed,
    #  'ActionController::NotImplemented'           => :not_implemented,
    #  'ActionController::InvalidAuthenticityToken' => :unprocessable_entity
    #
    # All other exceptions will result in a 500 (internal server error)
    case exception
    when ActionController::RoutingError
      # requests like /foo (unknown controller, 404)
    when ActionController::UnknownAction
      # requests like /misc/foo (known controller, unknown action, 404)
    when ActiveRecord::RecordNotFound
      # strictly speaking, should never get here (RecordNotFound is handled
      # by the record_not_found method above), but if we did the default 404
      # page would be fine
    when ActiveRecord::StaleObjectError,
         ActiveRecord::RecordInvalid,
         ActiveRecord::RecordNotSaved,
         ActionController::MethodNotAllowed,
         ActionController::NotImplemented,
         ActionController::InvalidAuthenticityToken
      # default handling is fine for all of these
    else
      # Internal Server Error (500): these are the ones we want to know about
      # TODO: may later want to rate limit these
      ExceptionMailer.deliver_exception_report exception, self, request
    end
    super exception
  end

  # uncomment this method to test what remote users will see
  # when there are errors (must be in production mode)
  #def local_request?
  #  false
  #end
end
