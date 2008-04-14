custom_atom_feed do |feed|
  feed.title "wincent.com: #{@issue.kind_string} \##{@issue.id}"
  feed.updated @issue.updated_at
  feed.entry @issue, :url => issue_url(@issue) + '#top' do |entry|
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
    feed.entry comment, :url => issue_url(@issue) + "\#comment_#{comment.id}" do |entry|
      entry.title "New comment (\##{@issue.comments.index(comment) + 1}) by #{comment.user ? comment.user.display_name : 'anonymous'}"
      entry.content comment.body.w, :type => 'html'
      # BUG: I expect we have the usual N + 1 problem here
      entry.author { |author| author.name comment.user ? comment.user.display_name : 'anonymous' }
    end
  end
end
