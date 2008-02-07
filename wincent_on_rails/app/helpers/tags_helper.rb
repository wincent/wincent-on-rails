module TagsHelper
  def scaled_tag tag
    link_to tag.name, tag_path(tag), :style => "font-size: #{1 + tag.normalized_taggings_count * 1}em;"
  end
end
