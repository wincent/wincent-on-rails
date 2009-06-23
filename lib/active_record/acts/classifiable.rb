module ActiveRecord
  module Acts
    module Classifiable
      def self.included base
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_classifiable
          class_eval do
            include ActiveRecord::Acts::Classifiable::InstanceMethods
          end
        end
      end # module ClassMethods

      module InstanceMethods
        def moderate_as_ham!
          begin
            # we don't want moderating a model to mark it as updated
            # this hack will work as long as we run single-threaded
            record = self.class.record_timestamps
            self.class.record_timestamps = false
            self.awaiting_moderation  = false
            self.save
          ensure
            self.class.record_timestamps = record
          end

          did_moderate if respond_to?(:did_moderate)
        end
      end # module InstanceMethods
    end # module Classifiable
  end # module Acts
end # module ActiveRecord

ActiveRecord::Base.class_eval { include ActiveRecord::Acts::Classifiable }
