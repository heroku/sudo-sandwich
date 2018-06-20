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

        expect(sandwich.reload.access_token_expires_at).to eq expires_time
      end
    end
  end
end
