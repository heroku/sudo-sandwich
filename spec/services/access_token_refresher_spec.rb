require 'rails_helper'

RSpec.describe AccessTokenRefresher do
  describe '#run' do
    it 'saves the new access_token for the sandwich' do
      access_token_from_fixture = 'fake-access-token'
      heroku_uuid = 'some-uuid'
      sandwich = Sandwich.create!(
        heroku_uuid: heroku_uuid,
        plan: 'test',
        access_token: 'old-access-token',
      )

      AccessTokenRefresher.new(sandwich_id: sandwich.id).run
      sandwich.reload

      expect(sandwich.access_token).to eq access_token_from_fixture
    end

    it 'saves the datetime when the new access token expires' do
      Timecop.freeze do
        current_time = Time.now.utc
        expiration_time = current_time - 10.minutes
        time = Time.now.utc
        expires_in_seconds_from_fixture = 28799
        expires_time = time + expires_in_seconds_from_fixture
        heroku_uuid = 'some-uuid'
        sandwich = Sandwich.create!(
          heroku_uuid: heroku_uuid,
          plan: 'test',
          access_token_expires_at: expiration_time,
        )

        AccessTokenRefresher.new(sandwich_id: sandwich.id).run

        expect(sandwich.reload.access_token_expires_at).to be_within(0.01.second).of expires_time
      end
    end
    it 'sends credentials in the POST body, not the query string' do
      sandwich = Sandwich.create!(heroku_uuid: 'some-uuid', plan: 'test', refresh_token: 'some-refresh-token')

      AccessTokenRefresher.new(sandwich_id: sandwich.id, client_secret: 'some-secret').run

      expect(
        a_request(:post, 'https://id.heroku.com/oauth/token')
          .with(body: { refresh_token: 'some-refresh-token', grant_type: 'refresh_token', client_secret: 'some-secret' })
      ).to have_been_made
      expect(a_request(:post, /id\.heroku\.com\/oauth\/token\?/)).not_to have_been_made
    end
  end
end
