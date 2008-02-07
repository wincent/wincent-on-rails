require 'wikitext'

class String

  # Return a localized version of the receiver in the specified locale, where locale is a string such as "en-US" or "es-ES".
  # Translation tables are lazily loaded from the database the first time a request is made for a translation in a particular locale.
  # If no locale is specified falls back to the current locale as returned by the Locale#current_locale method.
  # If there is no current locale or the requested locale cannot be found then returns the receiver.
  #
  # TODO: write tool that searches for "string".localized (or "string".l) pattern and autogenerates/autoupdates strings files.
  def localized(locale = nil)
    if locale.nil?
      locale = Locale.current_locale
    else
      locale = Locale.find_by_code locale
    end
    if locale.nil?
      self
    else
      locale.lookup self
    end
  end

  # Convenience shortcut for invoking the String.localized method.
  alias :l :localized

  def to_wikitext
    @@shared_wikitext_parser ||= Wikitext::Parser.new
    @@shared_wikitext_parser.parse self
  end

  # Convenience shortcut
  alias :w :to_wikitext

end
