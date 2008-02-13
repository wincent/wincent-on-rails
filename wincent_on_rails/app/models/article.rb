# This is not intended to be a community-driven wiki, so there are no author attributes or spam and moderation flags.
# Although note that the admin may selectively enable comments on a particular article.
class Article < ActiveRecord::Base
  has_many                :comments,  :as => :commentable
  validates_presence_of   :title
  validates_uniqueness_of :title
  validates_presence_of   :redirect,  :if => Proc.new { |a| a.body.blank? },
    :message => 'must be present if body is blank'
  validates_presence_of   :body,      :if => Proc.new { |a| a.redirect.blank? },
    :message => 'must be present if redirect is blank'
  validates_format_of     :redirect,  :with => /\A\s*((\[\[.+\]\])|(https?:\/\/.+))\s*\z/,
    :if => Proc.new { |a| !a.redirect.blank? },
    :message => 'must be a [[wikitext]] link or HTTP URL'
  acts_as_taggable

  attr_accessor   :pending_tags
  attr_accessible :title, :redirect, :body, :public, :accepts_comments, :pending_tags

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
