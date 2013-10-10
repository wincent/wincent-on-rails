module PostsHelper
  def comment_count number
    pluralizing_count number, 'comment'
  end
end
