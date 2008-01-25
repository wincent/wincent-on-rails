class CreateWords < ActiveRecord::Migration
  def self.up
    create_table :words do |t|
      t.string      :token          # the actual token, usually a word
      t.integer     :count          # number of comments/tickets/posts etc that this word appears in
      t.integer     :classification # spam, support ticket etc
      t.timestamps
    end
    # TODO: acts_as_classifiable for models, adds all the stuff necessary to make a model collaborate with the filtering mechanism
  end

  def self.down
    drop_table :words
  end
end
