require 'rails_helper'

RSpec.describe ExchangeGrantTokenJob do
  describe '#perform' do
    it 'calls the grant code exchanger class' do
      sandwich = Sandwich.create!(heroku_uuid: 123, plan: 'test', state: 'provisioned')
      exchanger_double = double(run: true)
      allow(GrantCodeExchanger).to receive(:new).and_return(exchanger_double)

      ExchangeGrantTokenJob.perform_now(sandwich_id: sandwich.id)

      expect(GrantCodeExchanger).to have_received(:new).with(
        sandwich_id: sandwich.id,
      )
      expect(exchanger_double).to have_received(:run)
    end

    context 'is provisioning' do
      it 'enqueues the provision plan job' do
        sandwich = Sandwich.create!(heroku_uuid: '123', plan: 'pbj', state: 'provisioning')
        exchanger_double = double(run: true)
        allow(GrantCodeExchanger).to receive(:new).and_return(exchanger_double)
        allow(ProvisionPlanJob).to receive(:perform_later)

        ExchangeGrantTokenJob.perform_now(sandwich_id: sandwich.id)

        expect(ProvisionPlanJob).to have_received(:perform_later).
          with(sandwich_id: sandwich.id)
      end
    end

    context 'is provisioned' do
      it 'does not enqueue the provisioning job' do
        sandwich = Sandwich.create!(heroku_uuid: '123', plan: 'test', state: 'provisioned')
        exchanger_double = double(run: true)
        allow(GrantCodeExchanger).to receive(:new).and_return(exchanger_double)
        allow(ProvisionPlanJob).to receive(:perform_later)

        ExchangeGrantTokenJob.perform_now(sandwich_id: sandwich.id)

        expect(ProvisionPlanJob).not_to have_received(:perform_later)
      end
    end
  end
end
