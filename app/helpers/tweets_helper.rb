module TweetsHelper
  def atom_title tweet
    stripped    = strip_tags tweet.body.w
    compressed  = stripped.gsub /\s+/, ' '
    compressed.strip!
    truncate compressed, :length => 80
  end

  def character_count tweet
    pluralizing_count tweet.rendered_length, 'character'
  end

  def link_to_update_preview
    link_to_remote 'update', common_options, :class => 'update_link'
  end

  def observe_body
    observe_field 'tweet_body', common_options.merge({ :frequency => 5.0 })
  end

  def common_options
    {
      :url => tweets_url,
      :method => 'post',
      :update => 'preview',
      :with => "'body=' + encodeURIComponent($('tweet_body').value)",
      :before => "Element.show('spinner')",
      :complete => "Element.hide('spinner')"
    }
  end
end
