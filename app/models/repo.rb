# The Repo model provides read-only access to an existing Git repository on
# disk.
#
# For security, the Repo model doesn't traverse the file system looking for
# repositories; it only "knows" about repostories that are explicitly set up
# by the administrator.
#
# Likewise, it doesn't support repository creation or any other operation
# which would modify the filesystem.
#
# It is essentially a simple container for metadata about an existing
# repository, and provides us with a Rails resource suitable for establishing
# associations with other models that will be of interest to the user, such
# as Ref (branch), Commit, Blob, Tree and GitTag (so named because we already
# have a Tag model that is used for another, non-Git purpose).
#
# Note that the Git repository itself is a kind of database, and it would be
# inefficient to create a parallel database store in our MySQL database that
# mirrored the same data. As such, these models are created only on demand
# when they are needed for such things as providing a "Commentable" instance.
# Because repository history may be rewritten (for example, via forced update)
# these models are never a replacement for reading the actual repository data
# off the disk via Git; they only ever augment the information that is returned
# by Git.
#
# Table fields:
#
#   string   "name"
#   string   "permalink"
#   string   "path"
#   string   "description"
#   string   "clone_url"
#   string   "rw_clone_url"
#   integer  "product_id"
#   boolean  "public",      :default => false
#   datetime "created_at"
#   datetime "updated_at"
#
class Repo < ActiveRecord::Base
  before_save :check_optional_attributes

  belongs_to :product
  validates_presence_of :name, :path, :permalink
  validates_uniqueness_of :clone_url, :product_id, :rw_clone_url,
    :allow_blank => true
  validates_uniqueness_of :name, :path, :permalink
  validates_format_of :path, :with => %r{\A(/([a-z0-9._-]+))+\z}i,
    :message => 'must have format "/foo/bar/baz"'
  validate :check_path_is_valid_git_repo
  attr_accessible :clone_url, :description, :name, :path, :permalink,
    :product_id, :public, :rw_clone_url

  scope :published, -> { where(public: true) }

  def to_param
    (changes['permalink'] && changes['permalink'].first) || permalink
  end

  # Provides access to underlying Git::Repo instance.
  def repo
    @repo ||= Git::Repo.new path
  end

private

  def check_path_is_valid_git_repo
    Git::Repo.new path unless path.blank?
  rescue Errno::ENOENT
    errors.add :path, 'does not exist'
  rescue Errno::EACCES
    errors.add :path, 'is not readable'
  rescue Git::NoRepositoryError
    errors.add :path, 'is not a valid Git repository'
  end

  def check_optional_attributes
    # empty strings for optional attributes will falsely trigger database-level
    # uniqueness constraints, so replace empty strings with nil
    self.clone_url = nil if self.clone_url.blank?
    self.rw_clone_url = nil if self.rw_clone_url.blank?
  end
end
