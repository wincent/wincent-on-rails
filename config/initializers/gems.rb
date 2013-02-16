require 'wikitext/preprocess'

Wikitext::Parser.shared_parser.img_prefix = '/system/images/'
Haml::Template::options[:ugly] = true
