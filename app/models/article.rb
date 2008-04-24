# This is not intended to be a community-driven wiki, so there are no author attributes or spam and moderation flags.
# Although note that the admin may selectively enable comments on a particular article.
class Article < ActiveRecord::Base
  has_many                :comments,
                          :as         => :commentable,
                          :extend     => Commentable,
                          :order      => 'comments.created_at',
                          :dependent  => :destroy
  belongs_to              :last_commenter, :class_name => 'User'
  validates_presence_of   :title
  validates_uniqueness_of :title
  validates_format_of     :title,
                          :with => /\A[^_\/]+\z/,
                          :message => 'must not contain underscores or slashes'
  validates_format_of     :redirect,
                          :with => /\A\s*((\[\[.+\]\])|(https?:\/\/.+)|(\/.+))\s*\z/,
                          :if => Proc.new { |a| !a.redirect.blank? },
                          :message => 'must be a [[wikitext]] link or HTTP URL'
  attr_accessible         :title, :redirect, :body, :public, :accepts_comments, :pending_tags
  acts_as_searchable      :attributes => [:title, :body]
  acts_as_taggable

  def self.find_with_param! param
    find_by_title(deparametrize(param)) || (raise ActiveRecord::RecordNotFound)
  end

  def self.find_recent paginator = nil
    options = { :conditions => { :public => true }, :order => 'updated_at DESC', :limit => 10 }
    options.merge!({ :offset => paginator.offset, :limit => paginator.limit }) if paginator
    find :all, options
  end

  # for the Atom feed
  def self.find_recent_excluding_redirects
    find :all, :conditions => "public = TRUE AND (redirect IS NULL OR redirect = '')", :order => 'updated_at DESC', :limit => 10
  end

  def validate
    if redirect.blank? && body.blank?
      errors.add_to_base 'must supply either redirect or body'
    end
  end

  # There are three kinds of redirects possible:
  #   1. Absolute URLs: http://example.com/
  #   2. Relative URLs: /issues/640
  #   3. Internal wiki links: [[foo]]
  # This method returns true if the receiver is an "internal wiki link" redirect.
  # We're interested in this property because we want to know when to display "redirected from" annotations
  # (which we only want for redirections _within_ the wiki)
  def wiki_redirect?
    !!(self.redirect? && self.redirect =~ /\A\s*\[\[.+\]\]\s*\z/)
  end

  # this is a string-to-string transformation, unlike to_param/from_param
  def self.deparametrize string
    string.gsub '_', ' '
  end

  def self.parametrize string
    string.gsub ' ', '_'
  end

  def to_param
    Article.parametrize title
  end
end
