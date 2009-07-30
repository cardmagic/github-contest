require 'models'
require 'ruby-debug'

repos = {}
users = {}
repos_popularity = Hash.new(0)
named_repos = {}

puts "Reading repos"

File.open("download/repos.txt") do |repos_file|
  repos_file.each do |line|
    repo = Repo.new(line.strip)
    repos[repo.id] = repo
    (named_repos[repo.username] ||= []) << repo
  end
end
Repo.repos = repos
Repo.named_repos = named_repos

puts "Reading users"

File.open("download/data.txt") do |data_file|
  data_file.each do |line|
    user_id, repo_id = line.strip.split(":").map{|x|x.to_i}
    user = (users[user_id] ||= User.new(user_id))
    user.follow(repos[repo_id])
    repos_popularity[repo_id] += 1
  end
end
Repo.repos_popularity = repos_popularity
User.users = users

puts "Reading langs"

File.open("download/lang.txt") do |lang_file|
  lang_file.each do |line|
    Lang.new(line.strip)
  end
end

puts "Writing results"

File.open("results.txt", "w") do |results|
  File.open("download/test.txt") do |test_file|
    test_file.each do |line|
      user_id = line.to_i
      user = users[user_id] || User.new(user_id)
      results << "#{user_id}:#{user.recommendations.join(",")}\n"
    end
  end
end