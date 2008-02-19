module ActiveRecord
  module Acts
    module Searchable
      def self.included base
        base.extend(ClassMethods)
        base.class_inheritable_accessor  :searchable_attributes
      end

      module ClassMethods
        # Options:
        #
        # <tt>:attributes</tt>:: a hash of attribute names to be indexed
        def acts_as_searchable options = {}
          class_eval do
            after_create                :create_needles
            after_update                :update_needles
            after_destroy               :destroy_needles
            self.searchable_attributes  = options[:attributes] || [] # the "self" is _not_ optional
            include ActiveRecord::Acts::Searchable::InstanceMethods
            extend ActiveRecord::Acts::Searchable::ClassMethods
          end
        end
      end # module ClassMethods

      # no class methods yet: may potentially add some later
      module ClassMethods; end

      module InstanceMethods
      private
        # Models may have any of the following:
        #   - user_id (eg comments): ownership applies, not sure about public/private yet
        #     (what if a comment is attached to a private model? I think the comment should inherit its user_id from its
        #      commentable object; eg. obj.commentable.public)
        #     can probably sidestep this issue: only admin can view comments in isolation; all others have to see them in context
        #     of their commentable controller... could also let users view their own comments and nothing more
        #     so basically, comments are always private, except for the admin, for whom "private" doesn't exist
        #   - user_id, public boolean (eg issues): public/private distinction and ownership applies
        #   - public boolean (eg articles, revisions): there is no explicit user id here because only the admin can create them
        #   - neither (eg tags, taggings): again, only the admin can create them
        #
        # Odd cases:
        #
        #   - emails: these have a user_id but they are not intended to be public nor searchable
        #
        def needle_user_id
          names = self.attribute_names
          if names.include?('public')
            if self.public
              return nil          # anyone can view this model
            else
              # TODO: decide what to do here
            end
          end
          if names.include? 'user_id'
            return self.user_id # non-public
          end
          return nil            # no ownership nor public/private distinction applies, so this is effectively public too
        end

        def create_needles
          model_class     = self.class.to_s
          model_id        = self.id
          user            = needle_user_id
          searchable_attributes.each do |attribute|
            attribute_name  = attribute.to_s
            value           = self.send(attribute)
            Needle.tokenize(value).each do |token|
              Needle.create :model_class    => model_class,
                            :model_id       => model_id,
                            :attribute_name => attribute_name,
                            :content        => token,
                            :user_id        => user
            end
          end
        end

        def update_needles
          destroy_needles
          create_needles
        end

        def destroy_needles
          Needle.delete_all :model_class => self.class.to_s, :model_id => self.id
        end
      end # module InstanceMethods
    end # module Searchable
  end # module Acts
end # module ActiveRecord

ActiveRecord::Base.class_eval { include ActiveRecord::Acts::Searchable }
