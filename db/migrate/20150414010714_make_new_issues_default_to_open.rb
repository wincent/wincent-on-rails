class MakeNewIssuesDefaultToOpen < ActiveRecord::Migration
  def change
    change_column :issues, :status, :integer,
      default: Issue::STATUS[:open], limit: 4
  end
end
