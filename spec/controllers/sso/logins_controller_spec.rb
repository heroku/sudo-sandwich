require 'rails_helper'

RSpec.describe Sso::LoginsController do
  describe 'POST /sso/login' do
    context 'resource token matches sha1 of vals passed in' do
      it 'redirects with a 302' do
        resource_id = '123'
        Sandwich.create!(heroku_uuid: resource_id, plan: 'test')
        resource_token = 'valid_token'
        resource_token_double = double(run: resource_token)
        allow(ResourceTokenCreator).to receive(:new).and_return(resource_token_double)

        post :create,
          params: {
          resource_id: resource_id,
          timestamp: '567',
          resource_token: resource_token,
        }

        expect(response.code).to eq "302"
      end
    end

    context 'resource token does not match sha1 of vals passed in' do
      it 'returns a 403' do
        resource_id = '123'
        timestamp = '567'
        resource_token = 'valid_token'
        invalid_resource_token = 'invalid_token'
        resource_token_double = double(run: invalid_resource_token)
        allow(ResourceTokenCreator).to receive(:new).and_return(resource_token_double)

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
