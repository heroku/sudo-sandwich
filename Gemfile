source 'https://rubygems.org'

ruby '~> 2.6.5'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'attr_encrypted', '~> 3.0.0'
gem 'delayed_job_active_record'
gem 'dotenv-rails', '>= 2.7.6'
gem 'excon'
gem 'pg'
gem 'puma', '~> 3.12'
gem 'rails', '~> 6.1.7.4'
gem 'rollbar'
gem 'sucker_punch'

group :development, :test do
  gem 'pry-rails'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :test do
  gem 'rails-controller-testing', '>= 1.0.5'
  gem 'rspec-rails', '~> 3.9', '>= 3.9.1'
  gem 'sinatra'
  gem 'timecop'
  gem 'webmock'
end
