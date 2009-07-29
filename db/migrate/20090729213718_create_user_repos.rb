class CreateUserRepos < ActiveRecord::Migration
  def self.up
    create_table :user_repos do |t|
      t.integer :repo_id, :user_id
    end

    add_index :user_repos, :repo_id
    add_index :user_repos, :user_id
  end

  def self.down
    drop_table :user_repos
  end
end
