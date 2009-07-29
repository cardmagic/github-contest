class CreateLanguages < ActiveRecord::Migration
  def self.up
    create_table :languages do |t|
      t.string :name
    end
    add_index :languages, :name
  end

  def self.down
    drop_table :languages
  end
end
