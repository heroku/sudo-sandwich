class Sandwich < ActiveRecord::Base
  attribute :oauth_grant_code
  attribute :access_token
  attribute :refresh_token

  attr_encrypted :oauth_grant_code, key: ENV['ENCRYPTION_KEY']
  attr_encrypted :access_token, key: ENV['ENCRYPTION_KEY']
  attr_encrypted :refresh_token, key: ENV['ENCRYPTION_KEY']
end
