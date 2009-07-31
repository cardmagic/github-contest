require 'models'
require 'apriori'

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
=begin

transactions = []
Repo.repos.each do |repo|
  repo[1].users.map{|user|user.repos - [repo[1]]}.flatten.each do |other_repo|
    transactions << [repo[1].id, other_repo]
  end
end

rules = Apriori.find_association_rules(transactions,
                          :min_items => 2,
                          :max_items => 5,
                          :min_support => 1, 
                          :max_support => 100, 
                          :min_confidence => 20)

Repo.apriori = Hash.new([])
rules.each do |rule|
  Repo.apriori[rule.antecedent.first] << [rule.consequent, rule.confidence]
end

IRB.start_session(Kernel.binding)
=end

puts "Sampling repos"

Repo.sample_repos = Repo.repos_popularity[0,2000].map{|repo|repo[1]}
User.sample_users = (User.users.map{|user|user[1].id} - IO.read("download/test.txt").split(/\s+/).map{|user_id|user_id.to_i})[0,2000]

#

puts "Building matrix"

$m = Linalg::DMatrix[
  *Repo.sample_repos.map do |repo_id|
    User.sample_users.map{|user_id|User.users[user_id].repos.include?(Repo.repos[repo_id]) ? 1 : 0}
  end
]

puts "Decomposing matrix"
u, s, v = $m.singular_value_decomposition

puts "Transpose matrix"
vt = v.transpose

#first and second columns of u
$u2 = Linalg::DMatrix.join_columns((0...2).to_a.map{|x|u.column(x)})
#first and second columns of vt
$v2 = Linalg::DMatrix.join_columns((0...2).to_a.map{|x|vt.column(x)})

puts "Finding eigenvalues"
$eig2 = Linalg::DMatrix.columns [s.column(0).to_a.flatten[0,2], s.column(1).to_a.flatten[0,2]]

puts "Writing results"

File.open("results.txt", "w") do |results|
  File.open("download/test.txt") do |test_file|
    test_file.each do |line|
      user_id = line.to_i
      user = users[user_id] || User.new(user_id)
      results << "#{user_id}:#{user.apriori_recommendations.join(",")}\n"
    end
  end
end