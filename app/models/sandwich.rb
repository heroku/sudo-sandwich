class Sandwich < ApplicationRecord
  BASE_PLAN = 'test'.freeze
  USAGE_PLAN = 'usage'.freeze
  PLAN_CONFIG = {
    BASE_PLAN => 'This is a test',
    'pbj' => 'Make me a PB&J!',
    'blt' => 'Make me a BLT!',
    USAGE_PLAN => 'This is a usage-based plan',
  }.freeze

  attribute :oauth_grant_code
  attribute :access_token
  attribute :refresh_token

  attr_encrypted :oauth_grant_code, key: ENV['ENCRYPTION_KEY']
  attr_encrypted :access_token, key: ENV['ENCRYPTION_KEY']
  attr_encrypted :refresh_token, key: ENV['ENCRYPTION_KEY']

  has_many :usages

  validates :plan, inclusion: { in: PLAN_CONFIG.keys }

  def not_provisioned?
    state != 'provisioned'
  end
end
