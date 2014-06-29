module ShortLink
  # Subset of legal path chars: http://tools.ietf.org/html/rfc3986#section-1.1.1
  # We skip =.,;:@!$&'()*+~_- because Twitter hyperlinkifies all but =
  # incorrectly.
  SHORT_LINK_CHARS = [
    '0'..'9',
    'a'..'z',
    'A'..'Z',
  ].map(&:to_a).join

  SHORT_LINK_BASE  = SHORT_LINK_CHARS.size
  SHORT_LINK_MAP   = Hash[SHORT_LINK_CHARS.chars.zip(0..SHORT_LINK_BASE)]
  SHORT_LINK_REGEX = /[#{Regexp.escape(SHORT_LINK_CHARS)}]+/

  def self.encode(id)
    result = ''

    begin
      result = SHORT_LINK_CHARS[id % SHORT_LINK_BASE] + result
      id /= SHORT_LINK_BASE
    end while id > 0

    result
  end

  def self.decode(id)
    result = 0

    id.chars.each do |char|
      # no need to check #has_key? here; trust the routes to keep out bad input
      result = result * SHORT_LINK_BASE + SHORT_LINK_MAP[char]
    end

    result
  end
end
