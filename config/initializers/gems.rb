require 'wikitext/rails'

Wikitext::Parser.shared_parser.img_prefix = '/system/images/'
Haml::Template::options[:ugly] = true
Haml::Tempalte::options[:format] = :html5
Sass::Plugin.options[:style] = :compact
Sass::Plugin.options[:template_location] = "#{Rails.root}/app/views/sass"
