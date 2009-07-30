class Repo
  attr_accessor :id, :username, :name, :created_at, :fork_id, :users, :popularity, :lang, :size
  
  def self.repos
    @@repos
  end

  def self.repos=(repos)
    @@repos = repos
  end

  def self.named_repos
    @@named_repos
  end

  def self.named_repos=(named_repos)
    @@named_repos = named_repos
  end
  
  def self.repos_popularity
    @@repos_popularity
  end
  
  def self.repos_popularity=(re)
    @@repos_popularity = re.sort_by{|x|-x[1]}
  end
  
  def self.find(id)
    Repo.repos[id]
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
    @popularity = 0
  end
  
  def followed(user)
    @users << user
    @popularity += 1
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
    recs += named_similar
    (recs + popular)[0,10]
  end
  
  def repo_ids
    @repo_ids ||= repos.map{|repo| repo.id}
  end
  
  def forked_masters
    forks = repos.map{|repo| repo.fork_id}.compact.uniq
    forks - repo_ids
  end
  
  def named_similar
    similar = repos.map{|repo| Repo.named_repos[repo.username] - [repo]}.flatten
    if similar == []
      return []
    else
      (similar - repos).sort_by{|repo|-repo.popularity}.map{|repo| repo.id}.uniq
    end
  end
  
  def popular
    Repo.repos_popularity[0,100].map{|repo| repo[0]} - repos.map{|repo| repo.id}
  end
end

class Lang
  attr_accessor :langs
  def initialize(string)
    rest = string.split(":")
    if repo = Repo.find(rest.shift.to_i)
      langs = rest.shift.split(",")
      @langs = langs.map{|lang|lang.split(";")}.sort_by{|lang| -lang[1].to_i}
      repo.lang = @langs.first[0]
      repo.size = @langs.first[1]
    end
  end
end