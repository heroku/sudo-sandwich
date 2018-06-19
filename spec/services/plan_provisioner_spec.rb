require 'rails_helper'

RSpec.describe PlanProvisioner do
  describe '#run' do
    it 'returns the expected response from api.heroku.com' do
      heroku_uuid = 'some-uuid'
      sandwich = Sandwich.create!(
        heroku_uuid: heroku_uuid,
        plan: 'test',
        access_token_expires_at: Time.now.utc + 1.day,
      )

      response = PlanProvisioner.new(sandwich_id: sandwich.id).run

      expect(JSON.parse(response)['state']).to eq 'provisioned'
    end

    context 'access token is expired' do
      it 'refreshes the access_token' do
        Timecop.freeze do
          current_time = Time.now.utc
          expiration_time = current_time - 10.minutes
          heroku_uuid = 'some-uuid'
          sandwich = Sandwich.create!(
            heroku_uuid: heroku_uuid,
            plan: 'pbj',
            access_token_expires_at: expiration_time,
          )
          refresher_double = double(run: true)
          allow(AccessTokenRefresher).to receive(:new).and_return(refresher_double)

          PlanProvisioner.new(sandwich_id: sandwich.id).run

          expect(AccessTokenRefresher).to have_received(:new).with(
            sandwich_id: sandwich.id,
          )
        end
      end
    end

    context 'access token is not expired' do
      it 'does not refresh the access token' do
        Timecop.freeze do
          current_time = Time.now.utc
          expiration_time = current_time + 10.minutes
          heroku_uuid = 'some-uuid'
          sandwich = Sandwich.create!(
            heroku_uuid: heroku_uuid,
            plan: 'pbj',
            access_token_expires_at: expiration_time,
          )
          allow(AccessTokenRefresher).to receive(:new)

          PlanProvisioner.new(sandwich_id: sandwich.id).run

          expect(AccessTokenRefresher).not_to have_received(:new)
        end
      end
    end
  end
end
