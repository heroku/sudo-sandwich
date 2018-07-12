require 'rails_helper'

RSpec.describe GrantCodeExchanger do
  describe '#run' do
    it 'saves the access_token and refresh_token for the sandwich' do
      refresh_token_from_fixture = 'fake-refresh-token'
      access_token_from_fixture = 'fake-access-token'
      heroku_uuid = 'some-uuid'
      sandwich = Sandwich.create!(heroku_uuid: heroku_uuid, plan: 'test')

      GrantCodeExchanger.new(sandwich_id: sandwich.id).run
      sandwich.reload

      expect(sandwich.access_token).to eq access_token_from_fixture
      expect(sandwich.refresh_token).to eq refresh_token_from_fixture
    end

    it 'saves the datetime when the access token expires' do
      Timecop.freeze do
        time = Time.now.utc
        expires_in_seconds_from_fixture = 28799
        expires_time = time + expires_in_seconds_from_fixture
        heroku_uuid = 'some-uuid'
        sandwich = Sandwich.create!(heroku_uuid: heroku_uuid, plan: 'test')

        GrantCodeExchanger.new(sandwich_id: sandwich.id).run

        expect(sandwich.reload.access_token_expires_at).to be_within(0.01.second).of expires_time
      end
    end
  end
end
