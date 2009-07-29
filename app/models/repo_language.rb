class RepoLanguage < ActiveRecord::Base
  belongs_to :language
  belongs_to :repo
end
