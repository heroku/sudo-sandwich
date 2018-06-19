require 'rails_helper'

RSpec.describe Heroku::DashboardController do
  describe '#show' do
    context 'session id does not match heroku_uuid' do
      it 'returns a 403' do
        heroku_uuid = 'correct'
        _sandwich = Sandwich.create!(heroku_uuid: heroku_uuid, plan: 'test')
        other_sandwich = Sandwich.create!(heroku_uuid: 'incorrect', plan: 'test')
        session[:sandwich_id] = other_sandwich.id

        get :show, params: { id: heroku_uuid }

        expect(response.code).to eq '403'
      end
    end

    context 'session id matches heroku uuid' do
      it 'returns a 200' do
        heroku_uuid = 'correct'
        sandwich = Sandwich.create!(heroku_uuid: heroku_uuid, plan: 'test')
        session[:sandwich_id] = sandwich.id

        get :show, params: { id: heroku_uuid }

        expect(response.code).to eq '200'
      end

      it 'shows the plan name for the heroku_uuid passed in' do
        heroku_uuid = '123'
        sandwich = Sandwich.create!(heroku_uuid: heroku_uuid, plan: 'blt')
        session[:sandwich_id] = sandwich.id

        get :show, params: { id: heroku_uuid }

        expect(assigns(:sandwich)).to eq sandwich
        expect(response.body).to eq("Your Sandwich plan is currently: blt")
      end
    end
  end
end
