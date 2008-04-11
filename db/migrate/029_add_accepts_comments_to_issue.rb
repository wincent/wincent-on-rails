class AddAcceptsCommentsToIssue < ActiveRecord::Migration
  class Issue < ActiveRecord::Base; end
  def self.up
    add_column :issues, :accepts_comments, :boolean, :null => false, :default => true
    Issue.update_all 'accepts_comments = TRUE'
  end

  def self.down
    remove_column :issues, :accepts_comments
  end
end
