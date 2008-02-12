# This is not intended to be a community-driven wiki, so there are no author attributes or spam and moderation flags.
# Although note that the admin may selectively enable comments on a particular article.
class Article < ActiveRecord::Base
  has_many              :comments,  :as => :commentable
  validates_presence_of :title
  # TODO: validate format of title etc

  acts_as_taggable

  attr_accessor :pending_tags

  # given @article with title "foo bar", wiki_path(@article) will return /wiki/foo%20bar
  def to_param
    title
  end

  def after_create
    # taggings are a "has many through" association so can only be set up after saving for the first time
    if pending_tags
      tag pending_tags
      pending_tags = nil
    end
  end
end
