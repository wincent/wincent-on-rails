module GitTagsHelper
  def tag_name git_tag
    git_tag.name.sub %r{\Arefs/tags/}, ''
  end
end # module GitTagsHelper
