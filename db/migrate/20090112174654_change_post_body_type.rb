class ChangePostBodyType < ActiveRecord::Migration
  def self.up
    # We don't use the expected value of 16777215 here or
    # MySQL will actually create LONGTEXT columns instead
    # of MEDIUMTEXT ones (it's probably multiplying the
    # limit value by three because the tables use UTF-8
    # encoding, and the byte size is therefore rolling over
    # into the LONGTEXT size range).
    change_column :posts, :body, :text, :limit => 262143
  end

  def self.down
  end
end
