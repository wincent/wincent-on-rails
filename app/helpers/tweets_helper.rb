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
end
