require 'utils'

module Reader
  
  def load_repos(file_path)
    repos = {}
    
    File.open(file_path) do |file|
      file.each do |line|
        r = Utils::Repo.new(line)
        repos[r.repo_id] = r
      end
    end
    
    repos
  end
  
  def load_user_data(file_path, repos)
    users = {}
    
    File.open(file_path) do |file|
      file.each do |line|
        user_id, repo_id = line.split(':')
        user_id &&= user_id.to_i
        repo_id &&= repo_id.to_i
        users[user_id] ||= Utils::User.new(user_id)
        users[user_id].watch_repo(repo_id)
        repos[repo_id].watched_by_user(user_id)
      end
    end
    
    [users, repos]
  end
  
  def load_test_candidates(file_path, users)
    candidates = []
    
    File.open(file_path) do |file|
      file.each do |line|
        user_id = line.to_i
        candidates << user_id
        users[user_id] ||= Utils::User.new(user_id)
      end
    end
    
    [candidates, users]
  end

  module_function :load_repos, :load_user_data, :load_test_candidates
end
