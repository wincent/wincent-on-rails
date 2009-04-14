# as of Rails 2.2 must set up gems in an initializer because
# doing it in environment.rb is too late whenever class
# caching is turned on
Wikitext::Parser.shared_parser.img_prefix = '/system/images/'
Haml::Template::options[:ugly] = true
Sass::Plugin.options[:style] = :compact
Sass::Plugin.options[:template_location] = "#{RAILS_ROOT}/app/views/sass"
