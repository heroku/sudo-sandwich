require 'rails_helper'

RSpec.describe ProvisionPlanJob do
  describe '#perform' do
    it 'calls the provision plan class' do
      sandwich = double(id: 123)
      provisioner_double = double(run: true)
      allow(PlanProvisioner).to receive(:new).and_return(provisioner_double)

      ProvisionPlanJob.perform_now(sandwich_id: sandwich.id)

      expect(PlanProvisioner).to have_received(:new).with(
        sandwich_id: sandwich.id,
      )
      expect(provisioner_double).to have_received(:run)
    end
  end
end
