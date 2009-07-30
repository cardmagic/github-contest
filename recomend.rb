require 'reader'
require 'writer'

module Contest
  def recomend(candidates, users, repos, repos_popularity)
    @candidates, @users, @repos, @repos_popularity = candidates, users, repos, repos_popularity
    answers = []
    @candidates.each do |cand_id|
      answers << find_candidate_recomendations(@users[cand_id])
    end
    answers
  end
  
  def find_candidate_recomendations(user)
    recomendations = []
    recomendations += find_unwatched_base_forks(user)
    recomendations += (@repos_popularity[0,100].map{|repo|repo[0]} - user.repos - recomendations)
    "#{user.user_id}:#{recomendations[0,10].join(',')}"
  end
  
  def find_unwatched_base_forks(user)
    base_forks = []
    user.repos.each do |repo_id|
      user_repo = @repos[repo_id]
      if user_repo.forked? && !user.repos.include?(user_repo.fork_base) && !base_forks.include?(user_repo.fork_base)
        base_forks << user_repo.fork_base
      end
    end
    base_forks
  end
  
  module_function :recomend, :find_candidate_recomendations, :find_unwatched_base_forks
end

repos = Reader.load_repos('download/repos.txt')
users, repos, repos_popularity = Reader.load_user_data('download/data.txt', repos)
candidates, users = Reader.load_test_candidates('download/test.txt', users)
Writer.write_results('results.txt', Contest.recomend(candidates, users, repos, repos_popularity))
