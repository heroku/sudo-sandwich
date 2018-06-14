require 'rails_helper'

RSpec.describe ExchangeGrantTokenJob do
  describe '#perform' do
    it 'calls the grant code exchanger class' do
      exchanger_double = double(run: true)
      allow(GrantCodeExchanger).to receive(:new).and_return(exchanger_double)
      heroku_uuid = 'uuid'
      oauth_grant_code = 'code'

      ExchangeGrantTokenJob.perform_now(
        heroku_uuid: heroku_uuid,
        oauth_grant_code: oauth_grant_code,
      )

      expect(GrantCodeExchanger).to have_received(:new).with(
        heroku_uuid: heroku_uuid,
        oauth_grant_code: oauth_grant_code,
      )
    end
  end
end
