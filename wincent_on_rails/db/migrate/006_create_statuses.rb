class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.string      :name,        :null => false
      t.string      :description, :null => false
      t.boolean     :closed,      :default => true,   :null => false
      t.boolean     :is_default,  :default => false,  :null => false  # only one status may be the default status
      t.integer     :position                                         # for acts_as_list
      t.timestamps
    end

    # database-level constraint to ensure uniqueness (validates_uniqueness_of vulnerable to races)
    add_index :statuses, :name, :unique => true

    # problem here is that some statuses only make sense for bug reports, others for feedback etc
    # TODO: think about how to localize these model fields
    Status.create! :name => 'Open (new)',                 :description => 'Newly submitted issues awaiting further classification',
                                                          :closed => false, :is_default => true
    Status.create! :name => 'Open (in progress)',         :description => 'Open issues currently in progress', :closed => false
    Status.create! :name => 'Open (on hold)',             :description => 'Open issues currently on hold', :closed => false
    Status.create! :name => 'Closed (fixed)',             :description => 'Fixed bugs'
    Status.create! :name => 'Closed (duplicate)',         :description => 'Duplicates of issues already being tracked'
    Status.create! :name => 'Closed (completed)',         :description => 'Completed feature requests'
    Status.create! :name => 'Closed (inactive)',          :description => 'Issues closed due to inactivity'
    Status.create! :name => 'Closed (not reproducible)',  :description => 'Issues closed because they cannot be reproduced locally'
    Status.create! :name => 'Closed (not a bug)',         :description => 'Bug reports which describe intended behaviour'
    Status.create! :name => 'Closed (not accepted)',      :description => 'Rejected issues'
    Status.create! :name => 'Closed (finalized)',         :description => 'Finalized issues'

  end

  def self.down
    remove_index  :statuses, :column => :name
    drop_table    :statuses
  end
end
