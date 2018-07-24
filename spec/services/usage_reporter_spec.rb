require 'rails_helper'

RSpec.describe UsageReporter do
  describe '#run' do
    context 'usage data for previous hour is present' do
      it 'sends usage data and saves errors if any' do
        datetime = DateTime.new(2018,7,11,4,5,0)

          Timecop.freeze(datetime) do
          heroku_uuid_from_fixture = 'addon-resource-uuid'
          errors_from_fixture = ["cannot submit duplicate usages for the same unit, add_on resource, and timestamp"]
          sandwich = Sandwich.create!(heroku_uuid: heroku_uuid_from_fixture, plan: Sandwich::USAGE_PLAN)
          accepted_usage = Usage.create!(
            timestamp: datetime.beginning_of_hour - 1.hour,
            sandwich: sandwich,
            unit: 'nibbles',
            quantity: 5,
            reported: false,
          )
          rejected_usage = Usage.create!(
            timestamp: datetime.beginning_of_hour - 1.hour,
            sandwich: sandwich,
            unit: 'nibbles',
            quantity: 6,
            reported: false,
          )

          described_class.new.run

          expect(accepted_usage.reload).to be_reported
          expect(rejected_usage.reload).not_to be_reported
          expect(rejected_usage.error_messages["unit"]).to eq errors_from_fixture
        end
      end
    end

    context 'usage data for previous hour is not present' do
      it 'does not send usage data' do
        heroku_uuid = 'some-uuid'
        sandwich = Sandwich.create!(heroku_uuid: heroku_uuid, plan: Sandwich::USAGE_PLAN)
        old_usage = Usage.create!(
          timestamp: 1.day.ago.beginning_of_hour,
          unit: "whatever",
          sandwich: sandwich,
          quantity: 10,
          reported: false,
        )

        described_class.new.run

        expect(old_usage.reload).not_to be_reported
      end
    end
  end
end
