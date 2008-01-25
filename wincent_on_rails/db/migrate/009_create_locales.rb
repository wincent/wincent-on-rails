class CreateLocales < ActiveRecord::Migration
  def self.up
    create_table :locales do |t|
      t.string      :code,          :null => false  # RFC 3066 locale code (serves as permalink id)
      t.string      :description,   :null => false  # human-readable description
      t.timestamps
    end

    Locale.create :code => 'en-US', :description => 'US English'
    Locale.create :code => 'es-ES', :description => 'Spanish (Spain)'
  end

  def self.down
    drop_table :locales
  end
end
