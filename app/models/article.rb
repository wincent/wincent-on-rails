# This is not intended to be a community-driven wiki, so there are no author
# attributes or moderation flags (although note that article comments are
# enabled by default).
class Article < ActiveRecord::Base
  # titles may contain anything other than underscores and slashes
  TITLE_REGEX         = %r{\A[^_/]+\z}

  include Linking

  has_many                :comments,
                          :as         => :commentable,
                          :extend     => Commentable,
                          :order      => 'comments.created_at',
                          :include    => :user,
                          :dependent  => :destroy
  belongs_to              :last_commenter, :class_name => 'User'
  validates_presence_of   :title
  validates_uniqueness_of :title
  validates_format_of     :title,
                          :with => TITLE_REGEX,
                          :message => 'must not contain underscores or slashes'
  validates_format_of     :redirect,
                          :with => /(#{LINK_REGEX})          |
                                    (#{EXTERNAL_LINK_REGEX}) |
                                    (#{RELATIVE_PATH_REGEX})/x,
                          :if => proc { |a| !a.redirect.blank? },
                          :message => 'must be a valid [[wiki]] link, HTTP/HTTPS URL or relative path'
  validates_length_of     :body, :maximum => 128 * 1024, :allow_blank => true
  validate                :check_redirect_and_body
  attr_accessible         :title, :redirect, :body, :public, :accepts_comments, :pending_tags
  acts_as_searchable      :attributes => [:title, :body]
  acts_as_taggable

  scope :published, where(:public => true)
  scope :recent, published.order('updated_at DESC').limit(10)

  # for the Atom feed
  scope :recent_excluding_redirects, lambda {
    table = Article.arel_table
    recent.where(table[:redirect].eq(nil).or(table[:redirect].eq('')))
  }

  # NOTE: MySQL will do a case-insensitive find here, so "foo" and "FOO" refer
  # to the same article
  def self.find_with_param! param, user = nil
    article = find_by_title! deparametrize(param)
    if !article.public? && (!user || !user.superuser?)
      raise ActionController::ForbiddenError
    end
    article
  end

  def check_redirect_and_body
    if redirect.blank? && body.blank?
      errors.add :body, "can't be blank unless a redirect is supplied"
      errors.add :redirect, "can't be blank unless a body is supplied"
    end
  end

  # There are three kinds of redirects possible:
  #   1. Absolute URLs: http://example.com/ or https://example.com/
  #   2. Relative URLs: /issues/640
  #   3. Internal wiki links: [[foo]]
  # This method returns true if the receiver is an "internal wiki link"
  # redirect. We're interested in this property because we want to know when to
  # display "redirected from" annotations (which we only want for redirections
  # _within_ the wiki)
  def wiki_redirect?
    !!(self.redirect? && self.redirect =~ LINK_REGEX)
  end

  def redirection_url
    url_for_link redirect
  end

  # this is a string-to-string transformation, unlike to_param/from_param
  def self.deparametrize string
    string.gsub '_', ' '
  end

  def self.parametrize string
    string.gsub ' ', '_'
  end

  # capitalize first word only IFF it is all lowercase
  def self.smart_capitalize string
    words = string.split
    if first = words.first
      words[0] = first.capitalize if first =~ /\A[a-z]+\z/
    end
    words.join(' ')
  end

  def to_param
    param = (changes['title'] && changes['title'].first) || title
    Article.parametrize param
  end
end
