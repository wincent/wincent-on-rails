module Linking
  # These simple regexes are for use in validations in the articles and links
  # models; they do not support the more sophisticated features of the wikitext
  # translator, such as optional link text.
  LINK_REGEX          = %r{\A\s*\[\[([^_/]+)\]\]\s*\z}
  EXTERNAL_LINK_REGEX = %r{\A\s*(https?://\S+)\s*\z}
  RELATIVE_PATH_REGEX = %r{\A\s*(/\S+)\s*\z}

  # Returns a redirection URL or path suitable for consumption by
  # redirect_to, with trailing and leading whitespace stripped.
  # Returns nil if there is no such redirect.
  def url_for_link link
    case link
    when LINK_REGEX                           # => [[foo bar]]
      '/wiki/' + Article.parametrize($~[1])   # => /wiki/foo_bar
    when EXTERNAL_LINK_REGEX                  # => http://example.com/
      $~[1]                                   # => http://example.com/
    when RELATIVE_PATH_REGEX                  # => /issues/100
      $~[1]                                   # => /issues/100
    else
      nil
    end
  end
end # module Linking
