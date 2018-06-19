class PlanProvisioner
  BASE_URL = 'https://api.heroku.com'

  def initialize(sandwich_id:)
    @sandwich_id = sandwich_id
  end

  def run
    if sandwich.access_token_expires_at < (Time.now.utc - 90)
      AccessTokenRefresher.new(sandwich_id: sandwich_id).run
    end

    perform_request.body
  end

  private

  attr_reader :sandwich_id

  def perform_request
    Excon.new(BASE_URL).post(
      path: "/addons/#{heroku_uuid}/actions/provision",
      headers: {
        'Accept' => 'application/vnd.heroku+json; version=3',
        'Authorization' => "Bearer #{access_token}",
        'Content-Type' => 'application/json',
      }
    )
  end

  def heroku_uuid
    sandwich.heroku_uuid
  end

  def access_token
    sandwich.access_token
  end

  def sandwich
    @_sandwich ||= Sandwich.find(sandwich_id)
  end

end
