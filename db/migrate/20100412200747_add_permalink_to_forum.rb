class AddPermalinkToForum < ActiveRecord::Migration
  def self.up
    add_column :forums, :permalink, :string, :null => false

    # go back and provide permalinks for existing forums
    Forum.all.each do |f|
      if f.permalink.blank?
        f.permalink = f.name.gsub(' ', '-').downcase
        f.save
      end
    end

    # add database-level uniqueness constraint
    add_index :forums, :permalink, :unique => true
  end

  def self.down
    remove_index :forums, :column => :permalink
    remove_column :forums, :permalink
  end
end
