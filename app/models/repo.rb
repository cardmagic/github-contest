class Repo < ActiveRecord::Base
  has_many :repo_languages
  has_many :languages, :through => :repo_languages
  has_many :user_repos
  has_many :users, :through => :user_repos
end
