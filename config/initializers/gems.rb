require 'wikitext/preprocess'

known_links = Set.new(Article.pluck(:title).map(&:downcase))
Wikitext::Parser.shared_parser.img_prefix = '/system/images/'
Wikitext::Parser.shared_parser.link_proc = lambda do |target|
  known_links.member?(target.downcase) ? nil : 'redlink'
end

Haml::Template::options[:ugly] = true
