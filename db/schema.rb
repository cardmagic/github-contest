# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090729213718) do

  create_table "languages", :force => true do |t|
    t.string "name"
  end

  add_index "languages", ["name"], :name => "index_languages_on_name"

  create_table "repo_languages", :force => true do |t|
    t.integer "repo_id"
    t.integer "language_id"
  end

  add_index "repo_languages", ["language_id"], :name => "index_repo_languages_on_language_id"
  add_index "repo_languages", ["repo_id"], :name => "index_repo_languages_on_repo_id"

  create_table "repos", :force => true do |t|
    t.integer "users_count", :default => 0
  end

  add_index "repos", ["users_count"], :name => "index_repos_on_users_count"

  create_table "user_repos", :force => true do |t|
    t.integer "repo_id"
    t.integer "user_id"
  end

  add_index "user_repos", ["repo_id"], :name => "index_user_repos_on_repo_id"
  add_index "user_repos", ["user_id"], :name => "index_user_repos_on_user_id"

  create_table "users", :force => true do |t|
  end

end
