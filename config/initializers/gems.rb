# as of Rails 2.2 must set up gems in an initializer because
# doing it in environment.rb is too late whenever class
# caching is turned on
Haml::Template::options[:ugly] = true
Sass::Plugin.options[:style] = :compact
Wikitext::Parser.shared_parser.img_prefix = '/system/images/'
