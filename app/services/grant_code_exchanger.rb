class GrantCodeExchanger
  GRANT_TYPE = 'authorization_code'
  BASE_URL = 'https://id.heroku.com'

  def initialize(sandwich_id:, client_secret: ENV.fetch('CLIENT_SECRET'))
    @sandwich_id = sandwich_id
    @client_secret = client_secret
  end

  def run
    sandwich.update!(
      access_token: response_body[:access_token],
      refresh_token: response_body[:refresh_token],
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
      headers: { "Content-Type" => "application/x-www-form-urlencoded" },
      body: URI.encode_www_form(
        code: sandwich.oauth_grant_code,
        grant_type: GRANT_TYPE,
        client_secret: client_secret,
      )
    )
  end

  def expires_at
    Time.now.utc + response_body[:expires_in]
  end
end
