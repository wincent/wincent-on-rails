custom_atom_feed do |feed|
  feed.title "wincent.com: #{@issue.kind_string} \##{@issue.id}"
  feed.updated @issue.updated_at

  # Rails 2.3.0 RC1 BUG: http://rails.lighthouseapp.com/projects/8994/tickets/2043
  feed.entry @issue, :url => issue_url(@issue, :format => nil) + '#top' do |entry|
    if @issue.awaiting_moderation?
      entry.title "#{@issue.kind_string} \##{@issue.id}"
      entry.content 'Currently awaiting moderation'
    else
      entry.title "#{@issue.kind_string} \##{@issue.id}: #{@issue.summary}"
      entry.content @issue.summary.w, :type => 'html'
    end
    entry.author { |author| author.name @issue.user ? @issue.user.display_name : 'anonymous' }
  end
  for comment in @comments
    # Rails 2.3.0 RC1 BUG: http://rails.lighthouseapp.com/projects/8994/tickets/2043
    url = issue_url(@issue, :format => nil) + "\#comment_#{comment.id}"
    feed.entry comment, :url => url do |entry|
      entry.title "New comment (\##{@issue.comments.index(comment) + 1}) by #{comment.user ? comment.user.display_name : 'anonymous'}"
      entry.content comment.body.w, :type => 'html'
      # BUG: I expect we have the usual N + 1 problem here
      entry.author { |author| author.name comment.user ? comment.user.display_name : 'anonymous' }
    end
  end
end
