module ActiveRecord
  module Acts
    module Taggable
      def self.included base
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_taggable
          class_eval do
            has_many      :taggings, :as => :taggable, :dependent => :destroy
            has_many      :tags,     :through => :taggings
            attr_writer   :pending_tags
            include ActiveRecord::Acts::Taggable::InstanceMethods
            extend ActiveRecord::Acts::Taggable::MoreClassMethods
            alias_method_chain :validate, :check_pending_tag_format
            alias_method_chain :after_save, :save_pending_tags
          end
        end
      end # module ClassMethods

      # only 1 class method so far: may potentially add some others later, like "find_with_tag" etc
      module MoreClassMethods
        def find_top_tags
          # note how we override the global taggings_count value with one scoped just to the taggable model
          Tag.find_by_sql <<-SQL
            SELECT    tags.id, name, COUNT(taggings.id) AS taggings_count
            FROM      tags
            JOIN      taggings
            ON        tags.id = taggings.tag_id
            WHERE     taggings.taggable_type = '#{self.to_s.downcase}'
            GROUP BY  tags.id
            ORDER BY  taggings_count DESC LIMIT 10
          SQL
        end
      end # module MoreClassMethods

      module InstanceMethods

        # Add one or more tags to the receiver.
        # See the documentation for the parse_tag_list method for information on how the tag names are extracted.
        # Duplicate tags are not re-added.
        def tag *args
          parse_tag_list(args).each { |tag| add_tag tag }
        end

        # Remove tags from the receiver.
        # See the documentation for the parse_tag_list method for information on how the tag names are extracted.
        def untag *args
          parse_tag_list(args).each { |tag| remove_tag tag }
        end

        # Returns an array of tag names indicating which tags have been applied to the receiver.
        # Use the tags method to get the actual Tags objects.
        def tag_names
          tags.collect { |tag| tag.name }
        end

        # For use in forms.
        # See the save_pending_tags method for more information.
        def pending_tags
          tag_names.join ' '
        end

      protected

        # taggings are a "has many through" association so can only be set up after saving for the first time
        def after_save_with_save_pending_tags
          result = after_save_without_save_pending_tags
          return result if pending_tags == @pending_tags # nothing to do
          return result if @pending_tags.nil? # nil means "no change", "" would mean "destroy all"
          taggings.destroy_all # not very efficient, but hopefully won't be doing this too often
          tag @pending_tags
          @pending_tags = nil
          return result
        end

        def validate_with_check_pending_tag_format
          validate_without_check_pending_tag_format
          # can't use a normal validates_format_of here because that uses an accessor
          # (which will always return only valid values)
          # must check the instance variable directly
          if @pending_tags and not (@pending_tags =~ /\A([a-z]+(.[a-z]+)*)*\z/)
            errors.add :tags, 'may only contain letters or periods'
          end
        end

      private

        # Returned a normalized list of tags (tag names are lower-cased and duplicates are removed) based on the input.
        # Expects an array of strings containing whitespace-delimited tag names.
        # Because whitespace is a delimiter you must use some other character to separate words within a single tag, for example:
        #   los.angeles
        # The input array may contain nested arrays.
        def parse_tag_list args
          tags = []
          args.flatten.each do |arg|
            # without the strip leading whitespace will cause an extra, empty element to be returned
            tags += arg.downcase.strip.split(/\s+/)
          end
          tags.uniq
        end

        # Adds the specified tag to the receiver, where tag is a String specifying the tag name.
        # Database level constraints are used to ensure that the same tag is not applied more than once to a given model.
        def add_tag tag
          t = Tag.find_or_create_by_name tag
          if t.id == nil
            # tag didn't save: probably because of a failed validation
            # what to do here? for now just silently ignore
          else
            self.tags << t
          end
        rescue ActiveRecord::ActiveRecordError => e
          # silently ignore duplicate entry errors
          raise e unless e.to_s.match(/Duplicate entry/i)
        end

        # Remove the specified tag from the receiver, where tag is a String specifying the tag name.
        # If the receiver has no such tag then no action is taken.
        def remove_tag tag
          # could optimize this by querying the Tagging model directly with :conditions
          # but this is an infrequently-travelled code path
          tag_object = Tag.find_by_name tag
          self.tags.delete(tag_object) if tag_object # no error if tag not present in this model
        end
      end # module InstanceMethods
    end # module Taggable
  end # module Acts
end # module ActiveRecord

ActiveRecord::Base.class_eval { include ActiveRecord::Acts::Taggable }
