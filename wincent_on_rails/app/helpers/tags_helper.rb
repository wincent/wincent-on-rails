module TagsHelper
  def scaled_tag tag
    # NOTE: that we report the full taggings count here: may want to exclude taggables to which the user doesn't have access
    link_to tag.name, tag_path(tag),
      :style => "font-size: #{1 + tag.normalized_taggings_count * 1}em;",
      :title => "#{item_count(tag.taggings_count)} tagged with '#{tag.name}'"
  end
end
