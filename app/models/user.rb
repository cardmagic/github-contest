class User < ActiveRecord::Base
  has_many :user_repos
  has_many :repos, :through => :user_repos
end
