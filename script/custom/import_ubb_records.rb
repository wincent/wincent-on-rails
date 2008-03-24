include ActionView::Helpers::SanitizeHelper

def user_for_ubb_user user
  User.find(:first, :include => :emails, :conditions => ['emails.address = ?', user.USER_REGISTRATION_EMAIL])
end

def ubb_text_to_wikitext text
  # unsophisticated approximation for now: can think about doing more later
  text.gsub!('<br />', "\n")
  strip_tags text
end

# convention here is local variables for the UBB records and instance variables for the new records
UbbUser.find(:all).each do |user|
  @user = user_for_ubb_user user
  if @user
    puts "skipping: #{user.USER_REGISTRATION_EMAIL} (already exists)"
  elsif user.USER_ID == 1
    puts "skipping: USER_ID 1 (the UBB.threads anonymous user)"
  elsif user.USER_IS_APPROVED != 'yes'
    puts "skipping: #{user.USER_REGISTRATION_EMAIL} (not approved)"
  elsif user.USER_IS_BANNED != 0
    puts "skipping: #{user.USER_REGISTRATION_EMAIL} (banned)"
  else
    begin
      display_name = user.USER_DISPLAY_NAME.gsub('_', ' ')
      @user = User.create(
        :passphrase => user.USER_PASSWORD,
        :passphrase_confirmation => user.USER_PASSWORD,
        :display_name => display_name
      )
      if @user.errors[:display_name]
        # in the data set, all the failures are caused by leading numbers of being underlength, so...
        @user.display_name = "import#{display_name}"
      end
      @user.save!
      @email = @user.emails.build(:address => user.USER_REGISTRATION_EMAIL)
      @email.save!
      @user.update_attribute(:verified, true)

      # timestamps can only be updated behind ActiveRecord's back
      registered = Time.at(user.USER_REGISTERED_ON).to_s(:db)
      User.update_all ['created_at = ?, updated_at = ?', registered, Time.now], ['id = ?', @user]

      puts "success: #{user.USER_REGISTRATION_EMAIL} (user created)"
    rescue Exception => exception
      puts "error: #{user.USER_REGISTRATION_EMAIL} (exception caught: #{exception})"
    end
  end
end

UbbForum.find(:all).each do |forum|

  # loop through all forums
  @forum =  Forum.find_by_name(forum.FORUM_TITLE) ||
            Forum.create!(:name => forum.FORUM_TITLE, :description => forum.FORUM_DESCRIPTION)
  puts "forum: #{@forum.name}"
  forum.ubb_topics.each do |topic|
    @user = user_for_ubb_user topic.ubb_user
    next if @user.nil? && topic.ubb_user.USER_ID != 1 # allow UBB.threads anonymous user

    # create topic, iterating over posts
    posts = topic.ubb_posts.sort { |a,b| a.POST_POSTED_TIME <=> b.POST_POSTED_TIME }
    if posts.length > 0
      @topic = @forum.topics.build(:title => topic.TOPIC_SUBJECT, :body => ubb_text_to_wikitext(posts[0].POST_BODY))
      @topic.view_count = topic.TOPIC_VIEWS
      @topic.user = @user
      @topic.save!
      puts "saved topic: #{topic.TOPIC_SUBJECT}"
      posts.shift
      comment_count = 0
      posts.each do |post|
        @user = user_for_ubb_user post.ubb_user
        next if @user.nil? && post.ubb_user.USER_ID != 1 # allow UBB.threads anonymous user
        @comment = @topic.comments.build(:body => ubb_text_to_wikitext(post.POST_BODY))
        @comment.user = @user
        @comment.save!
        comment_count += 1
        puts "saved comment by: #{@user ? @user.display_name : 'anonymous'}"

        # now update the comment timestamps: have to go behind ActiveRecord's back to do this otherwise it will override us
        created = Time.at(post.POST_POSTED_TIME)
        updated = Time.at(post.POST_LAST_EDITED_TIME)
        created = updated if updated < created
        created = created.to_s(:db)
        updated = updated.to_s(:db)
        Comment.connection.execute <<-SQL
          UPDATE  comments
          SET     created_at = '#{created}', updated_at = '#{updated}'
          WHERE   id = #{@comment.id}
        SQL
      end

      # now update the topic timestamps: have to go behind ActiveRecord's back to do this otherwise it will override us
      created = Time.at(topic.TOPIC_CREATED_TIME)
      updated = Time.at(topic.TOPIC_LAST_REPLY_TIME)
      created = updated if updated < created
      created = created.to_s(:db)
      updated = updated.to_s(:db)
      commented = comment_count > 0 ? updated : nil
      Topic.connection.execute <<-SQL
        UPDATE  topics
        SET     created_at = '#{created}', updated_at = '#{updated}', last_commented_at = '#{commented}'
        WHERE   id = #{@topic.id}
      SQL
    end
  end
end
