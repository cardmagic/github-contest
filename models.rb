require 'time'

class Repo
  attr_accessor :id, :username, :name, :created_at, :fork_id, :users, :popularity, :internal_popularity, :lang, :size
  
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
    internal_popularity_rank
    recs = []
    recs += named_similar
    (forked_masters + recs + popular_repos).map{|repo|repo.id}.select{|repo_id|repo_id > 0}[0,10]
  end
  
  def popular_languages
    begin
      @popular_languages ||= repos.map{|repo| repo.lang}
    rescue
      []
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
      (similar - repos).sort_by{|repo|-(repo.internal_popularity || repo.popularity)}.uniq
    end
  end
  
  def internal_popularity_rank
    @internal_rank = Hash.new(0)
    repos.map{|repo| repo.users - [self]}.flatten.each do |user|
      user.repos.each do |repo|
        @internal_rank[repo] += 1
      end
    end
    @internal_rank.each do |repo, rank|
      repo.internal_popularity = rank
    end
  end
  
  def popular_repos
    if @internal_rank.size > 0
      recs = @internal_rank.sort_by{|x|-x[1]}[0,100].map{|repo| repo[0]}
      if recs.size < 10
        recs + (Repo.repos_popularity[0,100].map{|repo| Repo.find(repo[0])} - repos - recs)
      else
        recs
      end
    else
      (Repo.repos_popularity[0,100].map{|repo| Repo.find(repo[0])} - repos)
    end
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