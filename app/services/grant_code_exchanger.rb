class GrantCodeExchanger
  GRANT_TYPE = 'authorization_code'

  def initialize(heroku_uuid:, oauth_grant_code:, client_secret: ENV.fetch('CLIENT_SECRET'))
    @heroku_uuid = heroku_uuid
    @oauth_grant_code = oauth_grant_code
    @client_secret = client_secret
  end

  def run
    response = RestClient.post(
      'https://id.heroku.com/oauth/token',
      {
        code: oauth_grant_code,
        grant_type: GRANT_TYPE,
        client_secret: client_secret,
      },
    )

    body = JSON.parse(response.body, symbolize_names: true)

    sandwich.update!(
      access_token: body[:access_token],
      refresh_token: body[:refresh_token],
    )
  end

  private

  attr_reader :heroku_uuid, :oauth_grant_code, :client_secret

  def sandwich
    @_sandwich ||= Sandwich.find_by(heroku_uuid: heroku_uuid)
  end
end
