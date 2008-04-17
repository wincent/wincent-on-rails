require 'additions/time'

module ApplicationHelper
  include CustomAtomFeedHelper

  # sets up the application layout
  def atom_link model = nil
    case model
    when Issue
      # for issues#show override default (/issues/show/123.atom) to provide shorter link (/issues/123.atom)
      @atom_link = auto_discovery_link_tag(:atom, issue_url(model) + '.atom')
    when NilClass
      # works for posts#index, wiki#index
      @atom_link = auto_discovery_link_tag(:atom, :format => 'atom')
    when Topic
      # this is a nested resource, so needs special handling
      @atom_link = auto_discovery_link_tag(:atom, forum_topic_url(model.forum, model) + '.atom')
    end
  end

  def page_title string
    @page_title = string # picked up in application layout
    haml_tag :h1, h(string)
  end

  def named_anchor name
    content_tag :a, '', :id => name, :name => name
  end

  def wikitext_cheatsheet
    link_to 'wikitext markup help', url_for(:controller => 'misc', :action => 'wikitext_cheatsheet'),
      :popup => ['height=700,width=400']
  end

  # Pretty formatting for model creation/update information.
  #
  # Examples:
  #   - yesterday
  #   - Created 4 hours ago, updated a few seconds ago
  #
  def timeinfo(model, precise = false)
    created = model.created_at
    updated = model.updated_at
    if precise  # always show exact date and time
      if created == updated
        created.to_s(:long)
      else
        "Created #{created.to_s(:long)}, updated #{updated.to_s(:long)}"
      end
    else        # show human-friendly dates ("yesterday", "2 hours ago" etc)
      created = created.distance_in_words
      updated = updated.distance_in_words
      if created == updated
        created
      else
        "Created #{created}, updated #{updated}"
      end
    end
  end

  def pluralizing_count number, thing
    # note that we sanitize thing because it can come from user params (eg. /tags/foo?type=article)
    if number == 1
      h "1 #{thing.singularize}"
    else
      h "#{number_with_delimiter(number)} #{thing.pluralize}"
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

  def scaled_tag tag, type = nil
    # NOTE: that we report the full taggings count here: may want to exclude taggables to which the user doesn't have access
    path = type ? tag_path(tag, :type => type) : tag_path(tag)
    link_to tag.name, path,
      :style => "font-size: #{1 + tag.normalized_taggings_count * 1}em;",
      :title => "#{item_count(tag.taggings_count)} tagged with '#{tag.name}'"
  end

  # For use in product pop-up menus in forms.
  def product_options
    Product.find(:all).collect { |product| [product.name, product.id] }
  end

  # Convert key names from "feature_request" etc to "feature request".
  # Again, for use in pop-up menus in forms.
  def underscores_to_spaces options
    options.collect { |k,v| [k.to_s.gsub('_', ' '), v] }
  end


  def tag_links object
    links = object.tags.collect do |tag|
      link_to tag.name, tag_path(tag), :title => "#{item_count(tag.taggings_count)} tagged with '#{tag.name}'"
    end
    links.length == 0 ? 'none' : links.join(", ")
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

  # prevent Haml from whitespace-damaging <pre> blocks which might be in wikitext markup (very hacky)
  def preserving &block
    real_tabs = buffer.instance_variable_get :@real_tabs
    buffer.instance_variable_set :@real_tabs, 0
    buffer.buffer << "<!-- Haml: start pre -->\n"
    yield
    buffer.buffer << "<!-- Haml: end pre -->\n"
    buffer.instance_variable_set :@real_tabs, real_tabs
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

  def admin_only &block
    if admin?
      haml_tag :div, { :class => 'admin' } do
        yield
      end
    end
  end

  # I would have preferred to stick this in the Comments helper seeing as it pertains to that model,
  # but given that the comment form is a partial, the only way it can find this method is if it is here.
  def polymorphic_comments_path comment
    # the case statement is a temporary hack until Rails 2.1 comes out
    # we can't do this dynamically for now because of irregularities in the route names
    # ie. articles have wiki paths instead of article paths
    # in 2.1 should be able to make them have article paths
    class_str = comment.commentable.class.to_s
    case class_str
    when 'Article'
      article = comment.commentable
      wiki_comment_path article, comment
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

  def link_to_commentable commentable
    case commentable
    when Article
      link_to commentable.title, wiki_path(commentable)
    when Issue
      link_to commentable.summary, issue_path(commentable)
    when Post
      link_to commentable.title, blog_path(commentable)
    when Topic
      link_to commentable.title, forum_topic_path(commentable.forum, commentable)
    when NilClass
      # could get here if there is an orphaned comment in the database
      # should never happen: but in case it does, emitting this string is probably better than crashing
      'deleted parent'
    else
      raise 'not implemented'
    end
  end

  def timeinfo_for_comment comment
    created = comment.created_at.distance_in_words
    updated = comment.updated_at.distance_in_words
    if created == updated
      created
    else
      "#{created}, edited #{updated}"
    end
  end
end
