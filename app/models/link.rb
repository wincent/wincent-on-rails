# Simple class with two purposes:
#
#   - providing links to other sites and counting the number of click-throughs.
#   - providing internal and external links using convenient slugs (for example
#     /links/google to redirect to google.com, or /links/menu-crash to link to
#     a "hot" bug in the issue tracker)
#
# This is a simple implementation that just counts the absolute number of
# clicks; it does not record the date and time of the click (for example),
# although this could be easily added later on if desired with a Clickthrough
# model.
class Link < ActiveRecord::Base
  include Linking

  validates_presence_of   :uri
  validates_uniqueness_of :uri
  validates_format_of     :uri,
                          :with => /(#{LINK_REGEX})          |
                                    (#{EXTERNAL_LINK_REGEX}) |
                                    (#{RELATIVE_PATH_REGEX})/x,
                          :message => 'must be a valid [[wiki]] link, HTTP/HTTPS URL or relative path'
  validates_uniqueness_of :permalink, :allow_nil => true
  validates_format_of     :permalink,
                          :with => /\A[a-z0-9\-]*\z/,
                          :allow_nil => true,
                          :message => 'may only contain lowercase letters, numbers and hyphens'
  attr_accessible         :uri,       :permalink

  def redirection_url
    url_for_link uri
  end

  def short_link
    'https://' + APP_CONFIG['short_link_host'] + '/' + ShortLink.encode(id)
  end

  def to_param
    # pretty permalinks if available, otherwise fall back to id
    (changes['permalink'] && changes['permalink'].first) || self.permalink || self.id
  end
end
