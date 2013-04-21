if twitter = YAML.load_file(Rails.root + 'config/twitter.yml')[Rails.env]
  Twitter.configure do |c|
    c.consumer_key       = twitter['consumer_key']
    c.consumer_secret    = twitter['consumer_secret']
    c.oauth_token        = twitter['oauth_token']
    c.oauth_token_secret = twitter['oauth_token_secret']
  end
end
