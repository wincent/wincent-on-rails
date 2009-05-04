module TweetsHelper
  def character_count tweet
    pluralizing_count tweet.rendered_length, 'character'
  end
end
