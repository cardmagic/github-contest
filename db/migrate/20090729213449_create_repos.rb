class CreateRepos < ActiveRecord::Migration
  def self.up
    create_table :repos do |t|
      t.integer :users_count, :default => 0
    end
    
    add_index :repos, :users_count
  end

  def self.down
    drop_table :repos
  end
end
