custom_atom_feed do |feed|
  feed.title "wincent.com: #{@forum.name} forum: #{@topic.title}"
  feed.updated last_activity(@topic, @comments)
  feed.entry(@topic, :url => forum_topic_url(@forum, @topic)) do |entry|
    entry.title @topic.title
    entry.author { |author| author.name(@topic.user ? @topic.user.display_name : 'anonymous') }
    entry.content @topic.body.w, :type => 'html'
  end
  for comment in @comments
    feed.entry(comment, :url => forum_topic_url(@forum, @topic) + "\#comment_#{comment.id}") do |entry|
      entry.title "#{@topic.title}: comment #{@comments.index(comment) + 1}"
      entry.author { |author| author.name(comment.user ? comment.user.display_name : 'anonymous') }
      entry.content comment.body.w, :type => 'html'
    end
  end
end
