class Repo
  attr_accessor :id, :username, :name, :created_at, :fork_id, :users
  
  def self.repos
    @@repos
  end

  def self.repos=(repos)
    @@repos = repos
  end
  
  def self.repos_popularity
    @@repos_popularity
  end
  
  def self.repos_popularity=(re)
    @@repos_popularity = re.sort_by{|x|-x[1]}
  end
  
  def initialize(string)
    if string.is_a?(String)
      rest = string.split(":")
      @id = rest.shift.to_i
      @username, rest = rest[0].split("/")
      rest = rest.split(",")
      @name = rest.shift
      @created_at = rest.shift
      @fork_id = rest.shift
    else
      @id = string
    end
    @users = []
  end
  
  def followed(user)
    @users << user
  end
end

class User
  attr_accessor :id, :repos
  
  def self.users
    @@users
  end

  def self.users=(users)
    @@users = users
  end
  
  def initialize(id)
    @id = id
    @repos = []
  end
  
  def follow(repo)
    repo.followed(self)
    @repos << repo
  end
  
  def recommendations
    recs = []
    recs += forked_masters
    recs += popular
    recs[0,10]
  end
  
  def forked_masters
    forks = repos.map{|repo| repo.fork_id}.compact.uniq
    forks - repos.map{|repo| repo.id}
  end
  
  def popular
    Repo.repos_popularity[0,100].map{|repo| repo[0]} - repos.map{|repo| repo.id}
  end
end
