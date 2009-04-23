# With Rails 2.2.0, load ordering became a whole lot more sensitive.
# Specifically, from 2.2.0 onwards models are _preloaded_ at the end of the initializer block.
# This manifested itself only in testing and production environments, where config.cache_classes is true.
# Leaving these require statements at the end of the environment.rb file (where they originally were) was too late;
# the model class and other files would be evaluated before the requires, so things like "acts_as_taggable" would raise exceptions.
# The requires themselves could not be moved inside or before the initializer block because their dependencies from Rails itself
# weren't yet available at that point.
# Putting them here insures that they are evaluated after the initializer block has done its work setting up dependencies,
# but before the model class and other files are evaluated.
# For some more details, see:
# http://groups.google.com/group/rubyonrails-talk/browse_thread/thread/9e1686365fefc0ba/b0b51afa0704b1fe#b0b51afa0704b1fe
require 'active_record/acts/classifiable'
require 'active_record/acts/taggable'
require 'active_record/acts/searchable'
require 'wincent/active_record/error_extensions'
require 'custom_atom_feed_helper'
require 'authentication'
require 'dynamic_javascript'
require 'sortable'
