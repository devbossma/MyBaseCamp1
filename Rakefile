require_relative "config/environment"
require "sinatra/activerecord/rake"

desc "Start the application"
task :server do
  if ENV["RACK_ENV"] == "develepment"
    sh "bundle exec puma -p 9292 config.ru"
  else
    sh "bundle exec rerun --background --ignore 'db/*' --ignore 'log/*' --pattern '**/*.{rb,ru,erb}' 'bundle exec puma -p 9292 config.ru'"
  end
end

desc "Start simple server (no auto-reload)"
task :simple_server do
  sh "bundle exec puma -p 9292 config.ru"
end

desc "Open console"
task :console do
  Pry.start
end

desc "Run migrations"
task :migrate do
  sh "bundle exec rake db:migrate"
end

desc "Create database"
task :create do
  sh "bundle exec rake db:create"
end
