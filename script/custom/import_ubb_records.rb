def user_for_ubb_user user
  User.find(:first, :include => :emails, :conditions => ['emails.address = ?', user.USER_REGISTRATION_EMAIL])
end

def ubb_text_to_wikitext text
  # unsophisticated approximation for now: can think about doing more later
  # may end up just stripping all HTML except for links
  text.gsub!('<br />', "\n")
  text.gsub!(/<i>|<\/i>/, "''")
  text.gsub!(/<b>|<\/b>/, "'''")
end

# convention here is local variables for the UBB records and instance variables for the new records
UbbUser.find(:all).each do |user|
  @user = user_for_ubb_user user
  if @user
    puts "skipping: #{user.USER_REGISTRATION_EMAIL} (already exists)"
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

    # create topic, iterating over posts
    posts = topic.ubb_posts.sort { |a,b| a.POST_POSTED_TIME <=> b.POST_POSTED_TIME }
    if posts.length > 0
      @topic = @forum.topics.build(:title => topic.TOPIC_SUBJECT, :body => ubb_text_to_wikitext(posts[0].POST_BODY))
      @topic.user = @user
      @topic.save!
      puts "saved topic: #{topic.TOPIC_SUBJECT}"
      posts.shift
      posts.each do |post|
        @user = user_for_ubb_user post.ubb_user
        next if @user.nil? # ie. banned or not approved user
        @comment = @topic.comments.build(:body => ubb_text_to_wikitext(post.POST_BODY))
        @comment.user = @user
        @comment.save!
        puts "saved comment by: #{@user.display_name}"

        # TODO: update comment timestamps
      end

      # TODO: update post timestamps
    end

    # TOPIC_CREATED_TIME 1070503998     <-- Time.at(number)
    # TOPIC_LAST_REPLY_TIME 1070594946

  end
end
