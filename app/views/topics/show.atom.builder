custom_atom_feed do |feed|
  feed.title "wincent.com: #{@forum.name} forum: #{@topic.title}"
  last_active_comment = @comments.max { |a, b| a.updated_at <=> b.updated_at }
  feed.updated(last_active_comment ? last_active_comment.updated_at : @topic.updated_at)

  # Rails 2.3.0 RC1 BUG: http://rails.lighthouseapp.com/projects/8994/tickets/2043
  feed.entry(@topic, :url => forum_topic_url(@forum, @topic, :format => nil)) do |entry|
    entry.title @topic.title
    entry.author { |author| author.name(@topic.user ? @topic.user.display_name : 'anonymous') }
    entry.content @topic.body.w, :type => 'html'
  end
  for comment in @comments
    # Rails 2.3.0 RC1 BUG: http://rails.lighthouseapp.com/projects/8994/tickets/2043
    feed.entry(comment, :url => forum_topic_url(@forum, @topic, :format => nil) + "\#comment_#{comment.id}") do |entry|
      entry.title "#{@topic.title}: comment #{@comments.index(comment) + 1}"
      entry.author { |author| author.name(comment.user ? comment.user.display_name : 'anonymous') }
      entry.content comment.body.w, :type => 'html'
    end
  end
end
