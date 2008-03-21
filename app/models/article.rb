# This is not intended to be a community-driven wiki, so there are no author attributes or spam and moderation flags.
# Although note that the admin may selectively enable comments on a particular article.
class Article < ActiveRecord::Base
  has_many                :comments,  :as => :commentable
  belongs_to              :last_commenter, :class_name => 'User'
  validates_presence_of   :title
  validates_uniqueness_of :title
  validates_format_of     :title,     :with => /\A[^_\/]+\z/,
    :message => 'must not contain underscores or slashes'
  validates_format_of     :redirect,  :with => /\A\s*((\[\[.+\]\])|(https?:\/\/.+))\s*\z/,
    :if => Proc.new { |a| !a.redirect.blank? },
    :message => 'must be a [[wikitext]] link or HTTP URL'
  acts_as_taggable
  attr_accessible :title, :redirect, :body, :public, :accepts_comments, :pending_tags, :tag_names_as_string

  # NOTE: this could be defined dynamically in acts_as_taggable
  def self.top_tags
    Tag.find_by_sql <<-SQL
      SELECT    tags.id, name, taggings_count
      FROM      tags
      JOIN      taggings
      ON        tags.id = taggings.tag_id
      WHERE     taggings.taggable_type = 'Article'
      GROUP BY  tags.id
      ORDER BY  taggings_count DESC LIMIT 10
    SQL
  end

  def validate
    if redirect.blank? && body.blank?
      errors.add_to_base 'must supply either redirect or body'
    end
  end

  def to_param
    title.gsub(' ', '_')
  end
end
