require 'digest/sha2'
require 'pathname'

# An attachment is a file upload that may exist independently as a stand-alone
# record, or attached to a "parent" record such as an issue, a blog post, a
# product release, or a wiki article.
#
# To avoid tying up a Unicorn worker we let the nginx upload module handle
# uploads, and when creating a new Attachment instance merely move the uploaded
# file into place once nginx hands it over. This is handled when setting the
# "temp_path" virtual attribute.
#
# Likewise, when downloading attachments we use the "X-Accel-Redirect" feature
# to delegate to nginx the work of actually serving the data. This is a "best
# of both worlds" scenario because it allows us to use Rails for access control
# and hit-counting, while leaving the heavy lifting to nginx.
#
# Table fields:
#
#   string      :digest
#   string      :path                   # relative to RAILS_ROOT/files/
#   string      :mime_type
#   integer     :user_id                # optional (may be anonymous)
#   string      :original_filename
#   integer     :filesize
#   integer     :attachable_id          # optional (may be "parent-less")
#   string      :attachable_type        # optional (may be "parent-less")
#   boolean     :awaiting_moderation
#   boolean     :public
#   timestamps
#
class Attachment < ActiveRecord::Base
  validates_uniqueness_of :digest
  validates_presence_of   :path, :mime_type, :original_filename, :filesize
  validates_format_of     :digest, :with => /\A[a-f0-9]{64}\z/
  validates_format_of     :path, :with => %r{\A[a-f0-9]{2}/[a-f0-9]{62}\z}
  attr_accessible         nil

  def self.basedir
    Rails.root + 'files'
  end

  # virtual (non-db) attribute for temp file (as passed in by nginx)
  def temp_path= temp
    prepare_digest
    prepare_path
    move_from_temp_path temp
  end

private

  @@counter = 0
  def prepare_digest
    time = Time.now
    @@counter += 1 # not threadsafe but a race here would be harmless anyway
    self.digest = Digest::SHA256.hexdigest(sprintf('%s%s%d%d%d%d%d%d',
      APP_CONFIG['attachment_salt'], original_filename, time.to_i, time.usec,
      $$, Thread.current.object_id, @@counter, rand(1_000_000)))
  end

  def path_prefix
    self.digest[0..1]
  end

  def basename
    self.digest[2..63]
  end

  def prepare_path
    self.path = path_prefix + '/' + basename
  end

  def absolute_path
    Attachment.basedir + path
  end

  def move_from_temp_path temp
    temp = Pathname.new(temp)
    raise unless temp.absolute?
    dir = Attachment.basedir + path_prefix
    FileUtils.mkdir_p(dir) unless File.exist?(dir)
    FileUtils.mv(temp, absolute_path)
  end
end
