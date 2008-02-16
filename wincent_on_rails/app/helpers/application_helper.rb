require 'additions/time'

module ApplicationHelper
  def page_title string
    @page_title = string # picked up in application layout
    open :h1, h(string)
  end

  def named_anchor name
    content_tag :a, '', :id => name, :name => name
  end

  # Pretty formatting for model creation/update information.
  #
  # Examples:
  #   - Created yesterday
  #   - Created 4 hours ago, last updated a few seconds ago
  #
  def timeinfo(model, precise = false)
    # BUG: in Spanish localization will be translated as "creado" (masculine) etc for both masculine and feminine models
    created = model.created_at
    updated = model.updated_at
    if precise  # always show exact date and time
      if created == updated
        'Created %s' % created.to_s(:long)
      else
        'Created %s, last updated %s' % [created.to_s(:long), updated.to_s(:long)]
      end
    else        # show human-friendly dates ("yesterday", "2 hours ago" etc)
      created = created.distance_in_words
      updated = updated.distance_in_words
      if created == updated
        'Created %s' % created
      else
        'Created %s, last updated %s' % [created, updated]
      end
    end
  end

  def pluralizing_count number, thing
    if number == 1
      "1 #{thing.singularize}"
    else
      "#{number} #{thing.pluralize}"
    end
  end

  # TODO: localize
  def item_count number
    pluralizing_count number, 'item'
  end

  def scaled_tag tag
    # NOTE: that we report the full taggings count here: may want to exclude taggables to which the user doesn't have access
    link_to tag.name, tag_path(tag),
      :style => "font-size: #{1 + tag.normalized_taggings_count * 1}em;",
      :title => "#{item_count(tag.taggings_count)} tagged with '#{tag.name}'"
  end

  def tag_links object
    links = object.tags.collect do |tag|
      link_to tag.name, tag_path(tag), :title => "#{item_count(tag.taggings_count)} tagged with '#{tag.name}'"
    end
    links.length == 0 ? 'none' : links.join(", ")
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

  def admin_only &block
    if admin?
      open :div, { :class => 'admin' } do
        yield
      end
    end
  end

  # I would have preferred to stick this in the Comments helper seeing as it pertains to that model,
  # but given that the comment form is a partial, the only way it can find this method is if it is here.
  def polymorphic_comments_path comment
    # the case statement is a temporary hack until Rails 2.1 comes out
    class_str = comment.commentable.class.to_s
    case class_str
    when 'Post'
      class_str = 'blog'
    when 'Aritcle'
      class_str = 'wiki'
    end
    send "#{class_str.underscore}_comments_path", comment.commentable
  end
end
