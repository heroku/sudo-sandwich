class Sandwich < ActiveRecord::Base
  PLAN_CONFIG = {
    'test' => 'This is a test',
    'pbj' => 'Make me a PB&J!',
    'blt' => 'Make me a BLT!',
  }.freeze

  attribute :oauth_grant_code
  attribute :access_token
  attribute :refresh_token

  attr_encrypted :oauth_grant_code, key: ENV['ENCRYPTION_KEY']
  attr_encrypted :access_token, key: ENV['ENCRYPTION_KEY']
  attr_encrypted :refresh_token, key: ENV['ENCRYPTION_KEY']

  validates :plan, inclusion: { in: PLAN_CONFIG.keys }
end
