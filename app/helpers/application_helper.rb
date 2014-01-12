require 'additions/time'

module ApplicationHelper
  # Returns the first 16 characters of a commit hash.
  def commit_abbrev sha1
    sha1[0..15]
  end

  # Returns the first 16 characters of a commit hash, wrapped in a span
  # with a title attribute containing the full hash (ie. a tooltip).
  def commit_abbrev_with_tooltip sha1
    content_tag(:span, commit_abbrev(sha1), title: sha1)
  end

  # Wraps the commit#author#time in a span of class "relative-date", and
  # converts it to an ActiveSupport::TimeWithZone so that the JavaScript
  # relativize_dates function can operate on it.
  def commit_author_time commit
    content_tag :span,
      commit.author.time.in_time_zone('UTC'),
      class: 'relative-date'
  end

  # Wraps the commit#committer#time in a span of class "relative-date", and
  # converts it to an ActiveSupport::TimeWithZone so that the JavaScript
  # relativize_dates function can operate on it.
  def commit_committer_time commit
    content_tag :span,
      commit.committer.time.in_time_zone('UTC'),
      class: 'relative-date'
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

  def page_title string
    @page_title = string # picked up in application layout
    haml_tag :h1, h(string)
  end

  # Inserts a tag that produces a Font Awesome icon corresponding to `names`.
  #
  #   icon('fast-forward')
  #   icon('play rotate-180')
  #
  def icon(*names)
    content_tag :i, '', class: names.map { |name| "icon-#{name}" }.join(' ')
  end

  def annotation(field, *annotation)
    "#{field}<br><span class=\"annotation\">#{annotation.join('<br>')}</span>".html_safe
  end

  def named_anchor(name)
    content_tag :a, '', id: name, name: name
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

  # declared here because used by both Forums and Topics controllers
  def topic_count number
    pluralizing_count number, 'topic'
  end

  # used in user#show, topic#show etc
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
    user ? link_to(user) : 'anonymous'
  end

  def link_to_model model
    case model
    when Issue
      link_to model.summary, model
    when Snippet
      link_to snippet_title(model), model
    when NilClass
      # could get here for an orphaned comment (shouldn't happen)
      'deleted record'
    else # Article, Post, Topic
      link_to model.title, model
    end
  end

  # in the interests of readable JavaScript source code in helpers this allows
  # us to use indentation and neatly format our JS across multiple lines, but
  # "compress" the output when it is actually used in templates inline.
  def inline_js js
    js.gsub(/\s+/, ' ').strip
  end

  def button_to_destroy_model model, options = {}
    button_to 'destroy', model, options.reverse_merge!(
      method: :delete,
      class:  'destructive',
      data:   { confirm:  'Are you sure?' },
    )
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
end
