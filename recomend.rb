require 'models'

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

def get_analyzed
  puts "Building transactions"

  transactions = Repo.repos.values.inject({}) do |trans, repo|
    trans[repo.id] ||= []
    trans[repo.id] += repo.users.map{|user|user.repos.map{|r|r.id} - [repo.id]}.flatten
    trans
  end;nil

  puts "Analyzing transactions"

  analyzed = transactions.inject({}) do |anal, v|
    repo_id, corr_repos = v
    total = corr_repos.size.to_f
    result = []
    tmp = corr_repos.inject({}) {|rs, other_repo_id| rs[other_repo_id] ? (rs[other_repo_id] += 1) : (rs[other_repo_id] = 1); rs}
    tmp.each do |other_repo_id, count|
      result << [other_repo_id, (10000*count/total).to_i, count]
    end
    anal[repo_id] = result.sort_by{|ap|-ap[1]}[0,100]
    transactions.delete(repo_id)
    result = nil
    anal
  end;nil
  
  analyzed
end

Repo.apriori = get_analyzed

def get_user_analyzed
  puts "Building user transactions"

  transactions = User.users.values.inject({}) do |trans, user|
    trans[user.id] ||= []
    trans[user.id] += user.repos.map{|repo|repo.users.map{|u|u.id} - [user.id]}.flatten
    trans
  end;nil

  puts "Analyzing user transactions"

  analyzed = transactions.inject({}) do |anal, v|
    user_id, corr_users = v
    total = corr_users.size.to_f
    result = []
    tmp = corr_users.inject({}) {|rs, other_user_id| rs[other_user_id] ? (rs[other_user_id] += 1) : (rs[other_user_id] = 1); rs}
    tmp.each do |other_user_id, count|
      result << [other_user_id, (10000*count/total).to_i, count]
    end
    anal[user_id] = result.sort_by{|ap|-ap[1]}.first
    transactions.delete(user_id)
    result = nil
    anal
  end;nil
  
  analyzed
end

User.apriori = get_user_analyzed


IRB.start_session(Kernel.binding)

require 'linalg'

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
=end

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