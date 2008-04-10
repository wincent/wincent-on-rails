require 'digest/sha1'

include ActionView::Helpers::SanitizeHelper

def user_for_bugzilla_user user
  User.find :first, :include => :emails, :conditions => ['emails.address = ?', user.login_name]
end

# convention here is local variables for the Bugzilla records and instance variables for the new records
BugzillaUser.find(:all).each do |user|
  @user = user_for_bugzilla_user user
  if @user
    puts "skipping #{user.login_name} (already exists)"
  else
    begin
      display_name = user.realname.clone
      display_name.gsub!(/[\-_\.']+/, ' ')
      display_name.gsub!(/ +/, ' ')
      display_name.strip!
      passphrase = Digest::SHA1.hexdigest(rand(1_000_000).to_s + user.userid.to_s + 'super-secret salt')
      @user = User.create :passphrase => passphrase, :passphrase_confirmation => passphrase, :display_name => display_name
      if @user.errors[:display_name]
        @user.display_name = "bugzilla user #{user.userid}"
        puts "error on display name, trying #{@user.display_name}"
      end
      @user.save!
      @email = @user.emails.build(:address => user.login_name)
      @email.save!
      @email.update_attribute(:verified, true)
      @user.update_attribute(:verified, true)

      # unlike in the UBB, Bugzilla doesn't seem to store registration date, so can't set that
      puts "success: #{user.login_name} (user created)"
    rescue ActiveRecord::RecordInvalid => e
      # for diagnostic purposes only
      puts "failed: #{user.login_name}, #{user.realname}"
      p e
    end
  end
end

def product_for_bugzilla_product product
  p = Product.find_by_name product.name
  if !p
    p = Product.create :name => product.name, :permalink => product.name.downcase.gsub(/[^a-z\.]/, '-')
    puts "created product: #{product.name}"
  end
  p
end

def cleanup_text text
  text = strip_tags text
  text.blank? ? nil : text
end

BugzillaProduct.find(:all).each do |product|
  product_for_bugzilla_product product
end

BugzillaBug.find(:all, :order => 'bug_id').each do |bug|
  @product = product_for_bugzilla_product bug.bugzilla_product
  comment = bug.bugzilla_comments.find :first, :order => 'bug_when'
  @creation = comment.bug_when
  @reporter = user_for_bugzilla_user comment.bugzilla_user
  @description = cleanup_text(comment.thetext) || 'empty'
  @issue = Issue.new :summary => bug.short_desc, :description => @description
  @issue.product = @product
  @issue.user = @reporter
  @issue.public = (comment.isprivate == 0)
  @issue.awaiting_moderation = false
  @issue.kind = Issue::KIND[:feature_request] if bug.short_desc =~ /request/i # otherwise just defaults to BUG
  case bug.bug_status
  when 'CLOSED', 'RESOLVED'
    @issue.status = Issue::STATUS[:closed]
  when 'ASSIGNED', 'REOPENED'
    @issue.status = Issue::STATUS[:open]
  end
  @issue.save!
  puts "created issue \##{@issue.id}: #{@issue.summary}"

  # without the :limit clause, :offset is ignored
  bug.bugzilla_comments.find(:all, :order => 'bug_when', :offset => 1, :limit => 1_000_000).each do |comment|
    @user = user_for_bugzilla_user comment.bugzilla_user
    @body = cleanup_text(comment.thetext)
    next if @body.nil?
    @comment = @issue.comments.build(:body => @body)
    @comment.user = @user
    @comment.awaiting_moderation = false
    @comment.public = (comment.isprivate == 0)
    @comment.save!
    puts "saved comment by: #{@user.display_name}"

    # timestamps can only be updated behind ActiveRecord's back
    timestamp = comment.bug_when
    Comment.update_all ['created_at = ?, updated_at = ?', timestamp, timestamp], ['id = ?', @comment]
    @update = timestamp
  end

  # CCs: the Bugzilla "cc" table doesn't even have a primary key, which ActiveRecord requires, so must cheat
  ccs = BugzillaComment.connection.execute "SELECT who FROM cc WHERE bug_id = #{bug.bug_id}"
  ccs.each do |u|
    @user = user_for_bugzilla_user BugzillaUser.find(u.first.to_i)
    @monitorship = @issue.monitorships.build
    @monitorship.user = @user
    @monitorship.save!
    puts "adding CC: #{@user.display_name}"
  end

  # now go back and alter timestamps on issue instance based on first and last comment dates
  Issue.update_all ['created_at = ?, updated_at = ?', @creation, @update], ['id = ?', @issue.id]
end
