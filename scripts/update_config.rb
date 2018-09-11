# I'm just pasting this into a console. hackity-hack-hack

BASE_URL = 'https://api.heroku.com'
sandwich = Sandwich.last

if sandwich.access_token_expires_at < (Time.now.utc - 90)
  AccessTokenRefresher.new(sandwich_id: sandwich_id).run
end

sandwich.reload

heroku_uuid = sandwich.heroku_uuid
access_token = sandwich.access_token

response = Excon.new(BASE_URL).patch(
  path: "/addons/#{heroku_uuid}/config",
  headers: {
    'Accept' => 'application/vnd.heroku+json; version=3',
    'Authorization' => "Bearer #{access_token}",
    'Content-Type' => 'application/json',
  },
  body: JSON.dump(
    config: [
      {
        name: "DJCPWICH_SUDO_SANDWICH_COMMAND",
        value: "from manual process",
      },
      {
        name: "DJCPWICH_SECOND_VAR",
        value: nil
      }
    ]
  )
)

# Doesn't contain DJCPWICH_SECOND_VAR
puts response.body

# But if you do `h config -a <the test app>` you can see DJCPWICH_SECOND_VAR is
# still there.
