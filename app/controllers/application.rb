class ApplicationController < ActionController::Base
  #helper                    :all # include all helpers, all the time
  filter_parameter_logging  'passphrase'
  before_filter             :login_before
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

  # uncomment this method to test what remote users will see when there are errors in production mode
  # def local_request?
  #   false
  # end
end
