module ReposHelper
  # Returns the first 16 characters of the commit hash.
  def commit_abbrev sha1
    sha1[0..15]
  end

  # Wraps the commit#author#time in a span of class "relative-date", and
  # converts it to an ActiveSupport::TimeWithZone so that the JavaScript
  # relativize_dates function can operate on it.
  def commit_author_time commit
    content_tag :span,
      commit.author.time.in_time_zone('UTC'),
      :class => 'relative-date'
  end

  # Wraps the commit#committer#time in a span of class "relative-date", and
  # converts it to an ActiveSupport::TimeWithZone so that the JavaScript
  # relativize_dates function can operate on it.
  def commit_committer_time commit
    content_tag :span,
      commit.committer.time.in_time_zone('UTC'),
      :class => 'relative-date'
  end
end
