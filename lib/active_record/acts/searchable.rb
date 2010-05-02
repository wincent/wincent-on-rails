module ActiveRecord
  module Acts
    module Searchable
      def self.included base
        base.extend ClassMethods
        base.class_inheritable_accessor  :searchable_attributes
      end

      module ClassMethods
        # Options:
        #
        # <tt>:attributes</tt>:: a hash of attribute names to be indexed
        def acts_as_searchable options = {}
          class_eval do
            self.searchable_attributes  = options[:attributes] || [] # the "self" is _not_ optional
            include ActiveRecord::Acts::Searchable::InstanceMethods
            set_callback :create, :after, :create_needles
            set_callback :update, :after, :update_needles
            set_callback :destroy, :after, :destroy_needles
          end
        end
      end # module ClassMethods

      module InstanceMethods
      private
        # Three ways to insert needles:
        #
        # (1) Use Needle.create
        #
        #     ActiveRecord is just _too_ slow to do it this way:
        #     with a relatively big post (40+KB) this takes about 30 seconds to save the article in development mode
        #
        #       Needle.create :model_class    => model_class,
        #                     :model_id       => model_id,
        #                     :attribute_name => attribute_name,
        #                     :content        => token,
        #                     :user_id        => user,
        #                     :public         => public
        #
        # (2) Use Needle.connection.insert, one needle at a time
        #
        #     This is 10 times faster (3 seconds), but still too slow:
        #
        #       Needle.connection.insert <<-SQL
        #         INSERT INTO needles (model_class, model_id, attribute_name, content, user_id, public)
        #         VALUES ('#{model_class}', #{model_id}, '#{attribute_name}', '#{token}', #{user}, #{public})
        #       SQL
        #
        # (3) Doing a multi-row INSERT using Needle.connection.execute
        #
        #     I tested this with a 10,000 word article and it took less than a second in development mode.
        def create_needles
          return if self.respond_to?(:awaiting_moderation?) && self.awaiting_moderation?
          model_class     = self.class.to_s
          model_id        = self.id
          model_public    = respond_to?(:public) ? self.public.to_s.upcase : 'TRUE'
          model_user      = (respond_to?(:user_id) ? self.user_id : nil) || 'NULL'
          values          = []
          searchable_attributes.each do |attribute|
            attribute_name  = attribute.to_s
            value           = self.send(attribute)
            next if value.nil?
            Needle.tokenize(value).each do |token|
              # must quote because tokens can be URLs and URLs can contain single quotes etc
              token = Needle.connection.quote_string(token)
              values << "('#{model_class}', #{model_id}, '#{attribute_name}', '#{token}', #{model_user}, #{model_public})"
            end
          end

          if values.length > 0
            sql = 'INSERT INTO needles (model_class, model_id, attribute_name, content, user_id, public) VALUES '
            sql << values.join(', ')
            Needle.connection.execute sql
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
