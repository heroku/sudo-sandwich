source 'https://rubygems.org'

ruby "~> 2.3.7"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


gem 'rails', '~> 5.1.1'
gem 'pg'
gem 'puma', '~> 3.7'
gem 'dotenv-rails'

group :development, :test do
  gem 'pry-rails'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :test do
  gem 'rspec-rails', '~> 3.6'
  gem 'webmock'
end
