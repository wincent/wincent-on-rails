require 'wikitext'

class String

  def to_wikitext
    # this is where we will add pre-filtering as well
    @@shared_wikitext_parser ||= Wikitext::Parser.new
    @@shared_wikitext_parser.parse self
  end

  # Convenience shortcut
  alias :w :to_wikitext

end
