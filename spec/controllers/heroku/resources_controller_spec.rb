require 'rails_helper'

RSpec.describe Heroku::ResourcesController do
  describe 'POST /heroku/resources' do
    it 'returns a 202' do
      post :create

      expect(response.code).to eq("202")
    end
  end
end
