class Locale < ActiveRecord::Base
  has_many              :translations, :dependent => :destroy
  validates_presence_of :code
  validates_presence_of :description

  # Can safely store the current locale in a class variable only because Rails is single-threaded.
  # The current locale should be set using a before_filter in the application controller.
  cattr_accessor        :current_locale

  # Looks up and returns a translation for the passed in string in the current locale.
  # If no translation is available returns the input string and prints a diagnostic notice to the console.
  # For testability we pass in the logger as a dependency.
  def lookup string, logger = RAILS_DEFAULT_LOGGER
    if @translations_cache.nil?
      # once off set-up (once per request); load translations from database and populate hash for fast access
      @translations_cache = {}
      self.translations.each { |t| @translations_cache[t.key] = t.translation }
    end
    translation = @translations_cache[string]
    if not translation.blank?
      translation
    else
      logger.info "#{self.code} locale missing translation for: #{string}"
      string
    end
  end

  # Helper class used in adding new translations to a locale.
  # For a usage example see the documentation for the Locale.translate method.
  # Rather than using a helper class I actually wanted to define the learn method in a module and then add
  # it to the collection proxy returned by ActiveRecord via extend. Unfortunately this doesn't work; for reasons
  # I've been unable to find out any attempt to send messages handled by the proxy (for example, the create! method)
  # raise a NoMethodError when called from within the module.
  class Learner
    def initialize collection
      @collection = collection
    end

    # See the documentation for the Locale.translate method for a usage example.
    def learn key, translation
      @collection.create! :key => key, :translation => translation
    end
  end

  # Allows for convenient addition of new translations to a locale using a DSL.
  #
  # Example:
  #
  #   spanish_locale.translate do |es|
  #     es.learn 'in the future',   'en el futuro'
  #     es.learn '%d minutes ago',  'hace %d minutos'
  #   end
  #
  def translate &block
    yield Learner.new(self.translations)
  end
end
