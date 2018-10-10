class AsyncPlanProvisioner
  BASE_URL = 'https://api.heroku.com'

  def initialize(sandwich_id:)
    @sandwich_id = sandwich_id
  end

  def run
    if sandwich.access_token_expires_at < (Time.now.utc - 90)
      AccessTokenRefresher.new(sandwich_id: sandwich_id).run
    end

    update_config_variable
    mark_addon_as_provisioned
    sandwich.update(state: 'provisioned')
  end

  private

  attr_reader :sandwich_id

  def update_config_variable
    Excon.new(BASE_URL).patch(
      path: "/addons/#{heroku_uuid}/config",
      headers: {
        'Accept' => 'application/vnd.heroku+json; version=3',
        'Authorization' => "Bearer #{access_token}",
        'Content-Type' => 'application/json',
      },
      body: JSON.dump(
        config: [
          {
            name: "SUDO_SANDWICH_COMMAND",
            value: Sandwich::PLAN_CONFIG[sandwich.plan],
          }
        ]
      ),
      expects: 200..299
    )
  end

  def mark_addon_as_provisioned
    Excon.new(BASE_URL).post(
      path: "/addons/#{heroku_uuid}/actions/provision",
      headers: {
        'Accept' => 'application/vnd.heroku+json; version=3',
        'Authorization' => "Bearer #{access_token}",
        'Content-Type' => 'application/json',
      },
      expects: 200..299
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
