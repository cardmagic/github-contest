class CreateRepoLanguages < ActiveRecord::Migration
  def self.up
    create_table :repo_languages do |t|
      t.integer :repo_id, :language_id
    end
    
    add_index :repo_languages, :repo_id
    add_index :repo_languages, :language_id
  end

  def self.down
    drop_table :repo_languages
  end
end
