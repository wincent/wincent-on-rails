# This is not intended to be a community-driven wiki, so there are no author attributes or spam and moderation flags.
# Although note that the admin may selectively enable comments on a particular article.
class Article < ActiveRecord::Base
  has_many    :revisions
  has_many    :comments,  :as => :commentable
  acts_as_taggable

  # returns nil if the receiver has no revisions
  def latest_revision
    revisions.find(:first, :order => 'created_at DESC')
  end

  def body= body
    if new_record?
      revision = revisions.build(:body => body)
    else
      super
    end
  end

  # given @article with title "foo bar", wiki_path(@article) will return /wiki/foo%20bar
  def to_param
    title
  end
end
