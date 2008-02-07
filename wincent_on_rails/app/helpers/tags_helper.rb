module TagsHelper
  def scaled_tag tag
    link_to tag.name, tag_path(tag), :style => 'font-size: 10pt;'
  end
end
