ENV['RAILS_ENV'] ||= 'production'

require File.dirname(__FILE__) + '/../config/boot'
require File.dirname(__FILE__) + '/../config/environment'

File.open("#{ARGV.first}/data.txt") do |f|
  begin
    loop do
      user_id, repo_id = f.readline.split(":")
      user = User.find_or_create_by_id(user_id)
      repo = Repo.find_or_create_by_id(repo_id)
      repo.users_count += 1
      repo.save
      join = UserRepo.create(:user_id => user_id, :repo_id => repo_id)
    end
  rescue
  end
end

File.open("#{ARGV.first}/lang.txt") do |f|
  begin
    loop do
      repo_id, langs = f.readline.split(":")
      repo = Repo.find_or_create_by_id(repo_id)
      
      lang = langs.split(",").map{|x|x.split(";")}.sort_by{|x|-x[1].to_i}.first[0]
      lang = Language.find_or_create_by_name(lang)
      
      join = RepoLanguage.create(:language_id => lang.id, :repo_id => repo_id)
    end
  rescue
  end
end