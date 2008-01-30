class CreateRevisions < ActiveRecord::Migration
  def self.up
    create_table :revisions do |t|
      t.integer     :article_id, :null => false
      t.text        :wikitext
      t.text        :html
      t.boolean     :public
      t.timestamps
    end
  end

  def self.down
    drop_table :revisions
  end
end
