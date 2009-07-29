class CreateFriends < ActiveRecord::Migration
  def self.up
    create_table :friends do |t|
      t.integer :user_id, :friend_id
      t.integer :similarities, :default => 0
    end
    
    add_index :friends, [:user_id, :similarities]
  end

  def self.down
    drop_table :friends
  end
end
