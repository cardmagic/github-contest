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
    Repo.repos[id.to_i] || Repo.new(id.to_i)
  end
  
  def initialize(string)
    if string.is_a?(String)
      rest = string.split(":")
      @id = rest.shift.to_i
      @username, rest = rest[0].split("/")
      rest = rest.split(",")
      @name = rest.shift
      @created_at = rest.shift
      @fork_id = rest.shift.to_i
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
    recs += named_similar
    (forked_masters + recs + popular_repos)[0,10].map{|repo|repo.id}
  end
  
  def popular_language
    begin
      @popular_language ||= repos.inject(Hash.new(0)){|languages, repo| languages[repo.lang] += 1}.sort_by{|langs| -langs[1]}.first[0]
    rescue
    end
  end
  
  def repo_ids
    @repo_ids ||= repos.map{|repo| repo.id}
  end
  
  def forked_masters
    forks = repos.map{|repo| repo.fork_id}.compact.uniq
    forks = (forks - repo_ids).map{|repo_id| Repo.find(repo_id)}
  end
  
  def named_similar
    similar = repos.map{|repo| Repo.named_repos[repo.username] - [repo]}.flatten
    if similar == []
      return []
    else
      (similar - repos).sort_by{|repo|-repo.popularity}.uniq.select{|repo| repo.size.nil? || repo.size > 2000}
    end
  end
  
  def popular_repos
    Repo.repos_popularity[0,100].map{|repo| Repo.find(repo[0])} - repos
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
      repo.size = @langs.first[1].to_i
    end
  end
end