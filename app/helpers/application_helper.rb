require 'additions/time'

module ApplicationHelper
  # Returns an appropriate CSS class to indicate whether the passed item
  # should be drawn as selected.
  def navbar_selected? item
    match = case controller
    when ArticlesController
      item == 'wiki'
    when CommentsController
      false
    when ProductsController
      item == 'products'
    when PostsController
      item == 'blog'
    else
      false
    end
    match ? 'selected' : nil
  end

  def page_title string
    @page_title = string # picked up in application layout
    haml_tag :h1, h(string)
  end

  # Inserts a tag that produces a Font Awesome icon corresponding to `names`.
  #
  #   icon('fast-forward')
  #   icon('play flip-horizontal')
  #
  def icon(*names)
    content_tag :i, '', class: ['fa'].concat(names.map { |name| "fa-#{name}" }).join(' ')
  end

  def named_anchor(name)
    content_tag :a, '', id: name, name: name
  end

  def wikitext_cheatsheet
    link_to 'wikitext markup', '/misc/wikitext_cheatsheet',
      'data-popup' => 'height=720,width=400',
      class: 'external'
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
  def timeinfo(model, options = {})
    created = model.created_at
    updated = model.updated_at
    if created.distance_in_words == updated.distance_in_words ||
      options[:updated_string] == false
      relative_date created
    else
      updated_string = options[:updated_string] || 'updated'
      "Created #{relative_date created}, #{updated_string} #{relative_date updated}".html_safe
    end
  end

  # return string wrapped in relative-date CSS span
  def relative_date(date)
    content_tag :time, date.xmlschema, data: { relative: true }
  end

  def pluralizing_count(number, thing)
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

  # used in user#show etc
  def comment_count number
    pluralizing_count number, 'comment'
  end

  # Translate, strip, then truncate wikitext markup.
  #
  # Explicitly checks for truncated entities before returning the output as an
  # HTML-safe string. If there is a truncated entity, it is deleted.
  #
  # See https://wincent.com/issues/1684 for more context, although note that
  # with Rails 4.0.0 the behavior of `#truncate` changed to always return an
  # HTML-safe string, like other helpers.
  def wikitext_truncate_and_strip(markup, options = {})
    squished  = strip_tags(markup.w).squish # may have entities, eg. &quot; etc
    truncated = truncate squished, options.merge(escape: false)
    if truncated == squished # string wasn't changed
      truncated.html_safe
    else # string was chopped
      omission = options[:omission] || '...'
      truncated.gsub! /&[^;]+?#{Regexp.escape omission}\z/, omission
      truncated.html_safe
    end
  end

  # used in snippet#index, tags#show etc
  def snippet_title snippet
    if snippet.description.blank?
      "Snippet \##{snippet.id}"
    else
      snippet.description
    end
  end

  def scaled_tag(tag, type = nil)
    # NOTE: that we report the full taggings count here: may want to exclude taggables to which the user doesn't have access
    path = type ? tag_path(tag, type: type) : tag
    link_to tag, path,
      style: "font-size: #{1 + tag.normalized_taggings_count * 1}em;",
      title: "#{item_count(tag.taggings_count)} tagged with '#{tag}'"
  end

  # given that the taggings count is wildly inaccurate here, not sure if I should use scaling here at all
  def scaled_filter_tag tag, tags
    tags  = [tags] unless tags.respond_to?(:collect)
    base  = tags.map(&:name).join(' ')
    query = "#{base} #{tag}"
    link_to tag, search_tags_path(q: "#{query}"),
      style: "font-size: #{1 + tag.normalized_taggings_count * 1}em;",
      title: "show items tagged with: #{query}"
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
    links.length == 0 ? 'no tags' : links.join(' ').html_safe
  end

  # Use whenever an item might be posted by an anonymous (nil) user;
  # comments, issues and so forth.
  def link_to_user(user)
    user ? link_to(user, user) : 'anonymous'
  end

  def link_to_model model
    case model
    when Article, Post
      link_to model.title, model
    when Snippet
      link_to snippet_title(model), model
    when NilClass
      # could get here for an orphaned comment (shouldn't happen)
      'deleted record'
    else
      # Could be a deleted model, like an Issue
      'missing record'
    end
  end
end
