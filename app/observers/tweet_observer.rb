require 'nokogiri'

# To keep the responsibility of the Tweet model simple and well-defined, it is
# solely responsible for modelling "tweets" as they are shown on this site.
#
# The TweetObserver model handles the integration with Twitter itself, watching
# for the creation of new records and propagating them to Twitter.
class TweetObserver < ActiveRecord::Observer
  class << self
    def twitter_config
      # https://dev.twitter.com/docs/api/1/get/help/configuration
      # suggests we check the configuration when loaded, but no more than once
      # a day; we do that, approximately, here
      if @twitter_config.nil? ||
        @twitter_config_last_checked && @twitter_config_last_checked < 24.hours.ago
        @twitter_config_last_checked = Time.now
        @twitter_config = Twitter.configuration
      end

      @twitter_config
    end
  end

  def short_url_length
    self.class.twitter_config.short_url_length_https
  end

  def after_create(tweet)
    update_text = update_text(tweet)

    # TODO: make this an actual async job
    update = Twitter.update(update_text)

    # yes, two updates in a row, but it's the easiest way to avoid updating
    # timestamps
    tweet.update_column(:twitter_id, update.id)
    tweet.update_column(:twitter_id_str, update.id_str)
  end

private

  TWEET_MAX_LENGTH = 140

  # We have to handle a range of inputs here:
  #
  #   [[look, an internal link!]]
  #   [https://google.com external]
  #   literal link http://apple.com, you see?
  #
  # We use Nokogiri to turn input like the above into:
  #
  #   look, an internal link! external literal link http://apple.com, you see?
  #
  # We know that each literal URL in the string will be shortened by Twitter, so
  # we tokenize that string to figure out how much of the string we can post
  # without going over budget.
  #
  # Finally, some of the budget is reserved for the link back to this site.
  #
  def update_text(tweet)
    text = Nokogiri::HTML(tweet.body.w).text
    tokens = tokenize_text(text)

    # leave room for link back to site
    budget = TWEET_MAX_LENGTH - ' '.length - short_url_length

    result = ''
    while budget > 0 && tokens.any?
      token = tokens.shift
      cost = (token.type == :uri ? short_url_length : token.value.length)
      break if budget < cost
      budget -= cost
      result += token.value
    end

    result + ' ' + tweet_url(tweet)
  end

  def tweet_url(tweet)
    # using Rails routing helpers here would be an uphill battle (see comments
    # in lib/sweeping.rb); these are stable-enough URls, so we hand-roll
    url = APP_CONFIG['protocol'] + '://' + APP_CONFIG['host']
    url += (':' + APP_CONFIG['port'].to_s) unless APP_CONFIG['port'].in?([80, 443])
    url + '/twitter/' + tweet.id.to_s
  end

  Token = Struct.new(:type, :value)
  URI_REGEX = %r{
    https?://                       # scheme
    [a-z0-9@$&'()*+=%_~/\#:!,;.?-]+ # URI chars
  }ix
  SPECIAL_URI_CHARS = /[:!(),;.?]/
  def tokenize_text(text)
    tokens = []
    scanner = StringScanner.new(text)

    while !scanner.eos?
      # tokenize (almost) like the Ragel-generated tokenizer in the wikitext gem
      if matched = scanner.scan(URI_REGEX)
        if matched[-1] =~ SPECIAL_URI_CHARS
          # this special case handles inputs like "Go to http://google.com/."
          matched = matched[0..-2]        # trim special char from end of match
          scanner.pos = scanner.pos - 1   # and bump scanner back
        end
        tokens << Token.new(:uri, matched)
      else
        matched = scanner.scan(/./)
        tokens << Token.new(:text, matched)
      end
    end

    tokens
  end
end
