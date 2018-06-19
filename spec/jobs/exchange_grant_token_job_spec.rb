require 'rails_helper'

RSpec.describe ExchangeGrantTokenJob do
  describe '#perform' do
    it 'calls the grant code exchanger class' do
      sandwich = double(id: 123, plan: 'test')
      exchanger_double = double(run: true)
      allow(GrantCodeExchanger).to receive(:new).and_return(exchanger_double)

      ExchangeGrantTokenJob.perform_now(
        sandwich_id: sandwich.id,
        sandwich_plan:  sandwich.plan
      )

      expect(GrantCodeExchanger).to have_received(:new).with(
        sandwich_id: sandwich.id,
      )
      expect(exchanger_double).to have_received(:run)
    end

    context 'plan that requires async provisioning' do
      it 'enqueues the provisioning job' do
        sandwich = double(id: '123', plan: 'pbj')
        exchanger_double = double(run: true)
        allow(GrantCodeExchanger).to receive(:new).and_return(exchanger_double)
        allow(ProvisionPlanJob).to receive(:perform_later)

        ExchangeGrantTokenJob.perform_now(
          sandwich_id: sandwich.id,
          sandwich_plan:  sandwich.plan
        )

        expect(ProvisionPlanJob).to have_received(:perform_later).
          with(sandwich_id: sandwich.id)
      end
    end

    context 'plan that does not require async provisioning' do
      it 'does not enqueue the provisioning job' do
        sandwich = double(id: '123', plan: Sandwich::BASE_PLAN)
        exchanger_double = double(run: true)
        allow(GrantCodeExchanger).to receive(:new).and_return(exchanger_double)
        allow(ProvisionPlanJob).to receive(:perform_later)

        ExchangeGrantTokenJob.perform_now(
          sandwich_id: sandwich.id,
          sandwich_plan:  sandwich.plan
        )

        expect(ProvisionPlanJob).not_to have_received(:perform_later)
      end
    end
  end
end
