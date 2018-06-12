class Sandwich < ActiveRecord::Base
  attribute :oauth_grant_code
  attr_encrypted :oauth_grant_code, key: ENV['ENCRYPTION_KEY']
end
