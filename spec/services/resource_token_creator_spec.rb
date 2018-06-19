require 'rails_helper'

RSpec.describe ResourceTokenCreator do
  describe '#run' do
    it "returns a token based on the values passed in" do
      resource_id = '123'
      timestamp = '567'

      resource_token = ResourceTokenCreator.new(
        heroku_uuid: resource_id,
        timestamp: timestamp,
        salt: 'salty',
      ).run

      expect(resource_token).to eq(
        '8bcafa70e186a8f9b85a1c93f3b6b0507748ec7a'
      )
    end
  end
end
