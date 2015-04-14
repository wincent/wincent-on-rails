class ConvertNewIssuesToOpenIssues < ActiveRecord::Migration
  def change
    Issue
      .where(status: Issue::STATUS[:new])
      .update_all(status: Issue::STATUS[:open])
  end
end
