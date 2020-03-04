source 'https://rubygems.org'

ruby "~> 2.5.1"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


gem 'rails', '~> 5.2.1'
gem 'pg'
gem 'puma', '~> 3.12'
gem 'dotenv-rails'
gem 'attr_encrypted', '~> 3.0.0'
gem 'delayed_job_active_record'
gem 'excon'
gem 'rollbar'
gem 'sucker_punch'

group :development, :test do
  gem 'pry-rails'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :test do
  gem 'rspec-rails', '~> 3.6'
  gem 'rails-controller-testing'
  gem 'sinatra'
  gem 'webmock'
  gem 'timecop'
end
