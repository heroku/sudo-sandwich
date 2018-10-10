class AccessTokenRefresher
  GRANT_TYPE = 'refresh_token'
  BASE_URL = 'https://id.heroku.com'

  def initialize(sandwich_id:, client_secret: ENV.fetch('CLIENT_SECRET'))
    @sandwich_id = sandwich_id
    @client_secret = client_secret
  end

  def run
    sandwich.update!(
      access_token: response_body[:access_token],
      access_token_expires_at: expires_at
    )
  end

  private

  attr_reader :sandwich_id, :client_secret

  def sandwich
    Sandwich.find(sandwich_id)
  end

  def response_body
    @_response_body ||= JSON.parse(response.body, symbolize_names: true)
  end

  def response
    Excon.new(BASE_URL).post(
      path: "/oauth/token",
      query: {
        refresh_token: sandwich.refresh_token,
        grant_type: GRANT_TYPE,
        client_secret: client_secret,
      },
      expects: 200..299
    )
  end

  def expires_at
    Time.now.utc + response_body[:expires_in]
  end
end
