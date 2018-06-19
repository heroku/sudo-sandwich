class ResourceTokenCreator
  def initialize(heroku_uuid:, timestamp:, salt: ENV['SSO_SALT'])
    @heroku_uuid = heroku_uuid
    @salt = salt
    @timestamp = timestamp
  end

  def run
    Digest::SHA1.hexdigest("#{heroku_uuid}:#{salt}:#{timestamp}")
  end

  private

  attr_reader :heroku_uuid, :salt, :timestamp
end
