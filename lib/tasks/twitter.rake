namespace :twitter do
  desc 'Copy tweets to snippets'
  task :migrate => :environment do
    Tweet.find_each do |tweet|
      puts "migrating tweet #{tweet.id}"

      # get accessible attributes first
      attributes = tweet.attributes.symbolize_keys
        .slice(:accepts_comments, :body, :public)
        .merge(pending_tags: tweet.tag_names.join(' '),
               markup_type: Snippet::MarkupType::WIKITEXT)

      Snippet.transaction do
        snippet = Snippet.create(attributes) do |snippet|
          # now handle inaccessible attributes
          snippet.created_at        = tweet.created_at
          snippet.updated_at        = tweet.updated_at
        end
        puts "created snippet #{snippet.id}"

        tweet.comments.each do |comment|
          puts "reattaching comment #{comment.id}"
          comment.commentable = snippet
          comment.save
        end

        tweet.accepts_comments = false
        if tweet.comments_count > 0
          tweet.comments_count = 0
          tweet.last_commenter_id = nil
          tweet.last_commented_at = nil
          tweet.last_comment_id   = nil
        end
        tweet.save
        puts "updated comment columns on tweet #{tweet.id}"
      end
    end
  end
end
