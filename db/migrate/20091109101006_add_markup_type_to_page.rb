class AddMarkupTypeToPage < ActiveRecord::Migration
  def self.up
    add_column :pages, :markup_type, :integer, :default => Page::MarkupType::HTML
    Page.update_all "markup_type = #{Page::MarkupType::HTML}"
  end

  def self.down
    remove_column :pages, :markup_type
  end
end
