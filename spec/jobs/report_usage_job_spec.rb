require 'rails_helper'

RSpec.describe ReportUsageJob do
  describe '#perform' do
    it 'calls the usage reporter class' do
      reporter_double = double(run: true)
      allow(UsageReporter).to receive(:new).and_return(reporter_double)

      ReportUsageJob.perform_now

      expect(UsageReporter).to have_received(:new)
      expect(reporter_double).to have_received(:run)
    end
  end
end
