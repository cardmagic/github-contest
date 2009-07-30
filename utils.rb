module Utils
  
  class Repo
    def initialize(line)
      @repo_id, values = line.split(':')
      name, created_at, @fork_base = values.split(',')
      @repo_id   &&= @repo_id.to_i
      @fork_base &&= @fork_base.to_i
      @users = []
    end
    
    attr_reader :repo_id, :fork_base, :users
    
    def forked?
      !!@fork_base
    end
    
    def watched_by_user(user_id)
      @users << user_id unless @users.include?(user_id)
    end
    
    def to_s
      "#{@repo_id} #{@fork_base} #{@users.join('_')}"
    end
  end
  
  class User
    def initialize(user_id)
      @user_id = user_id
      @repos = []
    end
    
    attr_reader :user_id, :repos
    
    def watch_repo(repo_id)
      @repos << repo_id unless @repos.include?(repo_id)
    end
    
    def to_s
      "#{@user_id} #{@repos.join('_')}"
    end
  end
end
