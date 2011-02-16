require 'additions/time'

module ApplicationHelper
  include CustomAtomFeedHelper

  # Returns the first 16 characters of a commit hash.
  def commit_abbrev sha1
    sha1[0..15]
  end

  # Wraps the commit#author#time in a span of class "relative-date", and
  # converts it to an ActiveSupport::TimeWithZone so that the JavaScript
  # relativize_dates function can operate on it.
  def commit_author_time commit
    content_tag :span,
      commit.author.time.in_time_zone('UTC'),
      :class => 'relative-date'
  end

  # Wraps the commit#committer#time in a span of class "relative-date", and
  # converts it to an ActiveSupport::TimeWithZone so that the JavaScript
  # relativize_dates function can operate on it.
  def commit_committer_time commit
    content_tag :span,
      commit.committer.time.in_time_zone('UTC'),
      :class => 'relative-date'
  end

  # Returns an appropriate CSS class to indicate whether the passed item
  # should be drawn as selected.
  def navbar_selected? item
    match = case controller
    when ArticlesController
      item == 'wiki'
    when CommentsController
      false
    when ForumsController
      item == 'forums'
    when IssuesController, SupportController
      item == 'support'
    when MiscController
      request[:action] == 'about' && item == 'about'
    when ProductsController
      item == 'products'
    when SearchController
      item == 'search'
    when TopicsController
      item == 'forums'
    when PostsController
      item == 'blog'
    else
      false
    end
    match ? 'selected' : nil
  end

  # sets up the application layout
  def atom_link model = nil
    case model
    when Issue
      @atom_link = auto_discovery_link_tag :atom, issue_path(model, :format => :atom)
    when Post
      @atom_link = auto_discovery_link_tag :atom, post_path(model, :format => :atom)
    when Topic
      @atom_link = auto_discovery_link_tag :atom, forum_topic_path(model.forum, model, :format => :atom)
    when String # "model" should actually be a URL here
      @atom_link = auto_discovery_link_tag :atom, model
    end
  end

  def feed_icon url
    link_to image_tag('feed-icon-14x14.png'), url
  end

  def page_title string
    @page_title = string # picked up in application layout
    haml_tag :h1, h(string)
  end

  def annotation field, *annotation
    "#{field}<br><span class=\"annotation\">#{annotation.join('<br>')}</span>".html_safe
  end

  def named_anchor name
    content_tag :a, '', :id => name, :name => name
  end

  def wikitext_cheatsheet
    link_to 'wikitext markup', '/misc/wikitext_cheatsheet',
      'data-popup' => 'height=720,width=400'
  end

  # Pretty formatting for model creation/update information.
  #
  # Examples:
  #   - yesterday
  #   - Created 4 hours ago, updated a few seconds ago
  #
  # Note that this method itself doesn't actually output relative dates;
  # rather, it wraps absolute dates in a "relative-date" CSS span and we
  # later relativize the spans on the fly using JavaScript (in this way
  # we can turn on page caching even for pages with relative dates on them).
  #
  # Accepts an options hash which may contain the following values:
  #   - :updated_string: joining string shown if a record has been
  #     updated/edited (default: 'updated'). If false, no updated date info is
  #     shown.
  def timeinfo model, options = {}
    created = model.created_at
    updated = model.updated_at
    if created.distance_in_words == updated.distance_in_words or options[:updated_string] == false
      relative_date created
    else
      updated_string = options[:updated_string] || 'updated'
      "Created #{relative_date created}, #{updated_string} #{relative_date updated}".html_safe
    end
  end

  # return string wrapped in relative-date CSS span
  def relative_date string
    %Q{<span class="relative-date">#{string}</span>}.html_safe
  end

  # This pattern is frequently used in Atom feeds, where the feed as a whole
  # should have an "updated" field that reflects the last modification to
  # either the main model itself (the first "entry" in the feed) or any of the
  # attached comments (the remaining "entry" spans).
  def last_activity model, comments
    updated_at = model.updated_at
    comments.each do |comment|
      updated_at = comment.updated_at if comment.updated_at > updated_at
    end
    updated_at
  end

  def pluralizing_count number, thing
    # note that we sanitize thing because it can come from user params (eg. /tags/foo?type=article)
    if number == 1
      "1 #{thing.singularize}"
    else
      "#{number_with_delimiter(number)} #{thing.pluralize}"
    end
  end

  def item_count number
    pluralizing_count number, 'item'
  end

  # declared here because used by both Forums and Topics controllers
  def topic_count number
    pluralizing_count number, 'topic'
  end

  # used in user#show, topic#show etc
  def comment_count number
    pluralizing_count number, 'comment'
  end

  # There are 3 possible approaches to wikitext truncation and stripping:
  #
  #   - translate -> strip -> truncate: HTML entities can appear in the
  #     view because "truncate" marks strings as not HTML-safe
  #   - translate -> truncate -> strip: we risk chopping entities and other
  #     markup in half, which will then appear in the view
  #   - truncate -> translate -> strip: we risk mangling the wikitext, and
  #     our actual length may be way off the desired length
  #
  # This method takes the first approach, but explicitly checks for truncated
  # entities before returning the output. If there is no truncated entity,
  # the output is marked HTML-safe; if there is a truncated entity, it is
  # deleted.
  #
  # See: https://wincent.com/issues/1684
  def wikitext_truncate_and_strip markup, options = {}
    stripped    = strip_tags markup.w # may have entities, eg. &quot; etc
    compressed  = stripped.gsub(/\s+/, ' ').strip
    truncated   = truncate compressed, options
    if truncated.html_safe? # string wasn't changed
      truncated
    else # string was chopped!
      omission = options[:omission] || '...'
      truncated.gsub! /&[^;]+?#{Regexp.escape omission}\z/, omission
      truncated.html_safe
    end
  end

  # used in tweet#index, tags#show etc
  def tweet_title tweet
    wikitext_truncate_and_strip tweet.body, :length => 80
  end

  # used in snippet#index, tags#show etc
  def snippet_title snippet
    if snippet.description.blank?
      "Snippet \##{snippet.id}"
    else
      snippet.description
    end
  end

  def scaled_tag tag, type = nil
    # NOTE: that we report the full taggings count here: may want to exclude taggables to which the user doesn't have access
    path = type ? tag_path(tag, :type => type) : tag_path(tag)
    link_to tag.name, path,
      :style => "font-size: #{1 + tag.normalized_taggings_count * 1}em;",
      :title => "#{item_count(tag.taggings_count)} tagged with '#{tag.name}'"
  end

  # given that the taggings count is wildly inaccurate here, not sure if I should use scaling here at all
  def scaled_filter_tag tag, tags
    tags  = [tags] unless tags.respond_to?(:collect)
    base  = tags.collect(&:name).join(' ')
    query = "#{base} #{tag.name}"
    link_to tag.name, search_tags_path(:q => "#{query}"),
      :style => "font-size: #{1 + tag.normalized_taggings_count * 1}em;",
      :title => "show items tagged with: #{query}"
  end

  # For use in AJAX product pop-up menus.
  # Take OrderedHash output from Product.categorized and massage it into
  # nested-arrays, suitable for conversion to JSON.
  def product_options
    Product.categorized.map do |category, products|
      [category, products.map { |product| [product.name, product.id] }]
    end
  end

  # Convert key names from "feature_request" etc to "feature request".
  # Again, for use in pop-up menus in forms.
  def underscores_to_spaces options
    options.collect { |k,v| [k.to_s.gsub('_', ' '), v] }
  end

  def breadcrumbs *crumbs
    content_tag :div, :id => 'breadcrumbs' do
      [link_to('Home', root_path), *crumbs].map do |crumb|
        crumb.html_safe? ? crumb : h(crumb)
      end.join(' &raquo; ').html_safe
    end
  end

  def tag_links object
    links = object.tags.collect do |tag|
      link_to tag.name, tag_path(tag), :title => "#{item_count(tag.taggings_count)} tagged with '#{tag.name}'"
    end
    links.length == 0 ? 'none' : links.join(' ').html_safe
  end

  # Use whenever an item might be posted by an anonymous (nil) user;
  # comments, topics, issues and so forth.
  def link_to_user user
    if user.nil?
      'anonymous'
    else
      link_to user.display_name, user_path(user)
    end
  end

  # TODO: potentially move these methods into authentication.rb as well
  def logged_in_only &block
    if logged_in?
      yield
    end
  end

  def logged_in_and_verified_only &block
    if logged_in_and_verified?
      yield
    end
  end

  def link_to_commentable commentable
    case commentable
    when Article
      link_to commentable.title, article_path(commentable)
    when Issue
      link_to commentable.summary, issue_path(commentable)
    when Post
      link_to commentable.title, post_path(commentable)
    when Snippet
      link_to snippet_title(commentable), snippet_path(commentable)
    when Topic
      link_to commentable.title, forum_topic_path(commentable.forum, commentable)
    when Tweet
      link_to tweet_title(commentable), tweet_path(commentable)
    when NilClass
      # could get here if there is an orphaned comment in the database
      # should never happen: but in case it does, emitting this string is probably better than crashing
      'deleted parent'
    else
      raise 'not implemented'
    end
  end

  def polymorphic_comments_path comment
    commentable = comment.commentable
    case commentable
    when Article, Issue, Post, Snippet, Tweet
      send "#{commentable.class.to_s.downcase}_comments_path", commentable
    when Topic
      forum_topic_comments_path commentable.forum, commentable
    end
  end

  def comment_form_path comment
    if comment.new_record?
      polymorphic_comments_path comment # eg. /issues/24/comments (create)
    else
      comment_path comment              # eg. /comments/34 (edit)
    end
  end

  # in the interests of readable JavaScript source code in helpers this allows
  # us to use indentation and neatly format our JS across multiple lines, but
  # "compress" the output when it is actually used in templates inline.
  def inline_js js
    js.gsub(/\s+/, ' ').strip
  end

  def button_to_destroy_model model, options = {}
    button_to 'destroy', model, options.reverse_merge!({
      :confirm  => 'Are you sure?',
      :method   => :delete,
      :class    => 'destructive'
    })
  end

  def button_to_moderate_model_as_ham model, url
    form_id = "#{model.class.to_s.downcase}_#{model.id}_ham_form"
    haml_tag :form, { :id => form_id, :style => 'display:inline;' } do
      onclick = inline_js <<-JS
          $.ajax({
            'url': '#{url}',
            'type': 'post',
            'dataType': 'json',
            'data': '_method=put&button=ham',
            'success': function() {
              $('\##{form_id}').fadeOut('slow');
            },
            'error': function() {
              alert('Failed to mark as ham');
            }
          });
        JS
      haml_tag :input, { :name => 'button', :onclick => onclick,
        :type => 'button', :value => 'ham' }
    end
  end

  def button_to_moderate_issue_as_ham issue
    button_to_moderate_model_as_ham issue, issue_path(issue)
  end

  def dynamic_javascript_include_tag
    klass = controller.class
    if klass.respond_to? :included_dynamic_javascript_actions
      return unless klass.included_dynamic_javascript_actions.include? params[:action].to_sym
    elsif klass.respond_to? :excluded_dynamic_javascript_actions
      return if klass.excluded_dynamic_javascript_actions.include? params[:action].to_sym
    else
      return unless klass.respond_to?(:uses_dynamic_javascript?) &&
                    klass.uses_dynamic_javascript?
    end

    # handle namespaces (controllers with superclasses)
    controllers = []
    loop do
      c = klass.to_s.gsub(/Controller$/, '')
      break if c == 'Application'
      controllers.unshift c.tableize
      break unless klass = klass.superclass
    end
    %Q{<script src="/js/#{controllers.join('/')}/#{params[:action].to_s}.js" type="text/javascript"></script>}.html_safe
  end

  def stylesheet_link_tags
    klass = controller.class
    if klass.respond_to? :included_stylesheet_link_actions
      return unless klass.included_stylesheet_link_actions.include? params[:action].to_sym
    elsif klass.respond_to? :excluded_stylesheet_link_actions
      return if klass.excluded_stylesheet_link_actions.include? params[:action].to_sym
    else
      return unless klass.respond_to?(:uses_stylesheet_links?) &&
                    klass.uses_stylesheet_links?
    end

    # handle namespaces (controllers with superclasses)
    controllers = []
    loop do
      c = klass.to_s.gsub(/Controller$/, '')
      break if c == 'Application'
      controllers.unshift c.underscore
      break unless klass = klass.superclass
    end
    stylesheet_link_tag controllers.join('/')
  end
end
