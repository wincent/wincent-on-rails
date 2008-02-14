# This is not intended to be a community-driven wiki, so there are no author attributes or spam and moderation flags.
# Although note that the admin may selectively enable comments on a particular article.
class Article < ActiveRecord::Base
  has_many                :comments,  :as => :commentable
  validates_presence_of   :title
  validates_uniqueness_of :title
  validates_format_of     :redirect,  :with => /\A\s*((\[\[.+\]\])|(https?:\/\/.+))\s*\z/,
    :if => Proc.new { |a| !a.redirect.blank? },
    :message => 'must be a [[wikitext]] link or HTTP URL'
  acts_as_taggable
  attr_accessible :title, :redirect, :body, :public, :accepts_comments, :pending_tags, :tag_names_as_string

  def validate
    if redirect.blank? && body.blank?
      errors.add_to_base 'must supply either redirect or body'
    end
  end

  def to_param
    title
  end
end
