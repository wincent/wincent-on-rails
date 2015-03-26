# Override example "wikitext/preprocess" that comes with wikitext gem.
class String
  def wikitext_preprocess
    self.
      # autolink hashtags, but only ones containing at least one letter
      gsub(
        %r{
          (?:$|\s)                          # only at start of line/after space
          \#(                               # will match a hashtag
            (?:[a-z0-9]*[a-z][a-z0-9]*)+    # "word" containing at least 1 letter
            (?:\.[a-z0-9]*[a-z][a-z0-9]*)*  # 0 or more ".word"
          )\b
        }ix,
        '[/tags/\1 #\1]'
      ).
      # same as in wikitext/preprocess:
      gsub(/\b(bug|issue|request|ticket) #(\d+)/i, '[/issues/\2 \1 #\2]')
  end
end
