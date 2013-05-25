require 'wikitext/preprocess'

Wikitext::Parser.shared_parser.img_prefix = '/system/images/'
Wikitext::Parser.shared_parser.link_proc = -> (target) {
  ArticleObserver.known_links.member?(target.downcase) ? nil : 'redlink'
}

Haml::Template::options[:ugly] = true
