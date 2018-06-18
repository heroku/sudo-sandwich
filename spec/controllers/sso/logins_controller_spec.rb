require 'rails_helper'

RSpec.describe Sso::LoginsController do
  describe 'POST /sso/login' do
    context 'resource token matches sha1 of vals passed in' do
      it 'redirects with a 302' do
        resource_id = '123'
        Sandwich.create!(heroku_uuid: resource_id, plan: 'test')
        timestamp = '567'
        resource_token = ResourceTokenCreator.new(
          heroku_uuid: resource_id,
          timestamp: timestamp
        ).run

        post :create,
          params: {
          resource_id: resource_id,
          timestamp: timestamp,
          resource_token: resource_token,
        }

        expect(response.code).to eq "302"
      end
    end

    context 'resource token does not match sha1 of vals passed in' do
      it 'returns a 403' do
        resource_id = '123'
        timestamp = '567'
        resource_token = ResourceTokenCreator.new(
          heroku_uuid: 'WRONG',
          timestamp: timestamp
        ).run

        post :create,
          params: {
          resource_id: resource_id,
          timestamp: timestamp,
          resource_token: resource_token,
        }

        expect(response.code).to eq "403"
      end
    end
  end
end
