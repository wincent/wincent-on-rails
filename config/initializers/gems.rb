require 'wikitext/preprocess'

Wikitext::Parser.shared_parser.img_prefix = '/system/images/'
Wikitext::Parser.shared_parser.link_proc = lambda do |target|
  Article.known_links.member?(target.downcase) ? nil : 'redlink'
end

Haml::Template::options[:ugly] = true
