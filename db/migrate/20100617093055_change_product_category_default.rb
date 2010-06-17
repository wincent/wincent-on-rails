class ChangeProductCategoryDefault < ActiveRecord::Migration
  def self.up
    change_column_default :products, :category, ''
    change_column :products, :category, :string, :null => false
  end

  def self.down
    # can't use this API to default value of NULL
    #   change_column_default :products, :category, nil
    Product.connection.execute 'ALTER TABLE products ALTER COLUMN category DROP DEFAULT'
    change_column :products, :category, :string, :null => true
  end
end
