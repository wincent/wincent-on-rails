module ActiveRecord
  module Acts
    module Taggable
      def self.included base
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_taggable
          class_eval do
            has_many      :taggings, :as => :taggable, :dependent => :destroy
            has_many      :tags,     :through => :taggings
            attr_accessor :pending_tags
            include ActiveRecord::Acts::Taggable::InstanceMethods
            extend ActiveRecord::Acts::Taggable::ClassMethods
          end
        end
      end # module ClassMethods

      # no class methods yet: may potentially add some later, like "find_with_tag" etc
      module ClassMethods; end

      module InstanceMethods

        # Add one or more tags to the receiver.
        # See the documentation for the parse_tag_list method for information on how the tag names are extracted.
        # Duplicate tags are not re-added.
        def tag *args
          parse_tag_list(args).each { |tag| add_tag(tag) }
        end

        # Remove tags from the receiver.
        # See the documentation for the parse_tag_list method for information on how the tag names are extracted.
        def untag *args
          parse_tag_list(args).each { |tag| remove_tag(tag) }
        end

        # Returns an array of tag names indicating which tags have been applied to the receiver.
        # Use the tags method to get the actual Tags objects.
        def tag_names
          self.tags.collect { |tag| tag.name }
        end

      public

        def tag_names_as_string
          tag_names.join(' ')
        end

        # Replace the receiver's existing tag array.
        def tag_names_as_string= *args
          taggings.destroy_all
          tag args
        end

      protected

        # unfortunately this will clash with any model that wants its own after_create method
        # so need to come up with a solution for that
        def after_create
          # taggings are a "has many through" association so can only be set up after saving for the first time
          if pending_tags
            tag pending_tags
            pending_tags = nil
          end
        end

      private

        # Returned a normalized list of tags (tag names are lower-cased and duplicates are removed) based on the input.
        # Expects an array of strings containing whitespace and command-delimited tag names.
        # Because whitespace is a delimiter you must use some other character to separate words within a single tag, for example:
        #   los.angeles
        # The input array may contain nested arrays.
        def parse_tag_list args
          tags = []
          args.flatten.each do |arg|
            # without the strip leading whitespace will cause an extra, empty element to be returned
            tags += arg.downcase.strip.split(/[\s,]+/)
          end
          tags.uniq
        end

        # Adds the specified tag to the receiver, where tag is a String specifying the tag name.
        # Database level constraints are used to ensure that the same tag is not applied more than once to a given model.
        def add_tag tag
          self.tags << Tag.find_or_create_by_name(tag)
        rescue ActiveRecord::ActiveRecordError => e
          # silently ignore duplicate entry errors
          raise e unless e.to_s.match(/Duplicate entry/i)
        end

        # Remove the specified tag from the receiver, where tag is a String specifying the tag name.
        # If the receiver has no such tag then no action is taken.
        def remove_tag tag
          # could optimize this by querying the Tagging model directly with :conditions
          # but this is an infrequently-travelled code path
          tag_object = Tag.find_by_name(tag)
          self.tags.delete(tag_object) if tag_object # no error if tag not present in this model
        end
      end # module InstanceMethods
    end # module Taggable
  end # module Acts
end # module ActiveRecord

ActiveRecord::Base.class_eval { include ActiveRecord::Acts::Taggable }
