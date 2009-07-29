class Repo < ActiveRecord::Base
  has_many :repo_languages
  has_many :languages, :through => :repo_languages
end
