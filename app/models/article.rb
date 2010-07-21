# This is not intended to be a community-driven wiki, so there are no author
# attributes or moderation flags (although note that article comments are
# enabled by default).
class Article < ActiveRecord::Base
  # titles may contain anything other than underscores and slashes
  TITLE_REGEX         = %r{\A[^_/]+\z}

  # for internal use only (see the links model/controller); does not support
  # the more sophisticated features of the wikitext translator, such as
  # optional link text
  LINK_REGEX          = %r{\[\[([^_/]+)\]\]}
  EXTERNAL_LINK_REGEX = %r{https?://.+?}
  RELATIVE_PATH_REGEX = %r{/.+?}

  # make "articles_path" helper available to redirection_url method
  include Rails.application.routes.url_helpers

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
                          :with => /\A\s* ((#{LINK_REGEX})          |
                                           (#{EXTERNAL_LINK_REGEX}) |
                                           (#{RELATIVE_PATH_REGEX}) )\s*\z/x,
                          :if => Proc.new { |a| !a.redirect.blank? },
                          :message => 'must be a valid [[wikitext]] link or HTTP/HTTPS URL'
  validates_length_of     :body, :maximum => 128 * 1024, :allow_blank => true
  validate                :check_redirect_and_body
  attr_accessible         :title, :redirect, :body, :public, :accepts_comments, :pending_tags
  acts_as_searchable      :attributes => [:title, :body]
  acts_as_taggable

  scope :published, where(:public => true)
  scope :recent, published.order('updated_at DESC').limit(10)
  scope :recent_with_offset, lambda { |offset| recent.offset(offset.to_i) }

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
      raise ActionController::ForbiddenError.new
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
  # This method returns true if the receiver is an "internal wiki link" redirect.
  # We're interested in this property because we want to know when to display "redirected from" annotations
  # (which we only want for redirections _within_ the wiki)
  def wiki_redirect?
    !!(self.redirect? && self.redirect =~ /\A\s*\[\[.+\]\]\s*\z/)
  end

  # Returns a redirection URL or path suitable for consumption by
  # redirect_to, with trailing and leading whitespace stripped.
  # Returns nil if there is no such redirect.
  def redirection_url
    # TODO: refactor these regexps for reuse (see validations)
    if redirect.nil?
      nil
    elsif redirect =~ /\A\s*#{LINK_REGEX}\s*\z/
      articles_path + '/' + Article.parametrize($~[1])
    elsif redirect =~ /\A\s*(#{EXTERNAL_LINK_REGEX})\s*\z/
      $~[1]
    elsif redirect =~ /\A\s*(#{RELATIVE_PATH_REGEX})\s*\z/
      $~[1]
    else
      nil
    end
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
