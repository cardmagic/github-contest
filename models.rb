class Repo
  attr_accessor :id, :username, :name, :created_at, :fork_id, :users, :popularity, :internal_popularity, :lang, :size
  
  def self.repos
    @@repos
  end

  def self.repos=(repos)
    @@repos = repos
  end
  
  def self.apriori
    @@apriori
  end
  
  def self.apriori=(apriori)
    @@apriori = apriori
  end

  def self.sample_repos
    @@sample_repos
  end

  def self.sample_repos=(repos)
    @@sample_repos = repos
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
  
  def self.apriori
    @@apriori
  end
  
  def self.apriori=(apriori)
    @@apriori = apriori
  end

  def self.users
    @@users
  end

  def self.users=(users)
    @@users = users
  end
  
  def self.sample_users
    @@sample_users
  end

  def self.sample_users=(users)
    @@sample_users = users
  end
  
  def initialize(id)
    @id = id
    @repos = []
  end
  
  def follow(repo)
    repo.followed(self)
    @repos << repo
  end
  
  def apriori_recommendations
    recs = []
    more_recs = []
    
    if repos.size > 0
      repo_ids = repos.map{|x|x.id}
      repos.each do |repo|
        if Repo.apriori.has_key?(repo.id)
          recs += Repo.apriori[repo.id].select{|ap|!repo_ids.include?(ap[0])}[0,10]
        end
      end
      recs = recs.select{|ap|ap[2] > 5}.sort_by{|ap|-ap[1]}.map{|ap|ap[0]}
    
#      if similar_user = User.users[User.apriori[id]]
#        more_recs += (similar_user.repos - repos).sort_by{|repo|-repo.popularity}
#      end
    end
    
    recs
  end
  
  def recommendations
    internal_popularity_rank
    named_similar.map{|repo|repo.id}.select{|repo_id|repo_id > 0}[0,50]
  end
  
  def svd
    require 'linalg'
      
    mine = Linalg::DMatrix[Repo.sample_repos.map {|repo_id| repos.include?(Repo.repos[repo_id]) ? 1 : 0}]
    mineEmbed = mine * $u2 * $eig2.inverse
    
    user_sim = {}
    $v2.rows.each_with_index do |x, count|
      user_sim[count] = (mineEmbed.transpose.dot(x.transpose)) / (x.norm * mineEmbed.norm)
    end
    
    if similar_users = user_sim.delete_if {|k,sim| sim.nan? || sim < 0.9 }.sort {|a,b| b[1] <=> a[1] }
      not_watched = []
      my_items = mine.transpose.to_a.flatten

      how_many = similar_users.size < 10 ? similar_users.size : 10
      
      how_many.times do |j|
        similar_users_items = $m.column(similar_users[j][0]).transpose.to_a.flatten

        my_items.each_index do |i|
          not_watched << Repo.repos[Repo.sample_repos[i]] if my_items[i] == 0 and similar_users_items[i] != 0
        end
      end
    
      not_watched.sort_by {|repo| -repo.popularity }.uniq
    else
      []
    end
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

  def double_forked_masters
    forks = forked_masters.map{|repo| repo.fork_id}.compact.uniq
    forks = (forks - repo_ids).map{|repo_id| Repo.find(repo_id)}
  end

  def forked_master_ids
    forks = repos.map{|repo| repo.fork_id}.compact.uniq
    forks = (forks - repo_ids)
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
    if @internal_rank && @internal_rank.size > 0
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

require 'irb'

module IRB
  def self.start_session(binding)
    IRB.setup(nil)

    workspace = WorkSpace.new(binding)

    if @CONF[:SCRIPT]
      irb = Irb.new(workspace, @CONF[:SCRIPT])
    else
      irb = Irb.new(workspace)
    end

    @CONF[:IRB_RC].call(irb.context) if @CONF[:IRB_RC]
    @CONF[:MAIN_CONTEXT] = irb.context

    trap("SIGINT") do
      irb.signal_handle
    end

    catch(:IRB_EXIT) do
      irb.eval_input
    end
  end
end
