require 'rails_helper'

describe ApplicationController do
  it "returns a 200 when correct basic auth credentials used" do
    env = Rails.env
    begin
      Rails.env = 'production'
      http_login(ENV['SLUG'], ENV['PASSWORD'])

      get :index

      expect(response.code).to eq "200"
    ensure
      Rails.env = env
    end
  end

  it "returns a 401 with incorrect basic auth credentials used" do
    env = Rails.env
    begin
      Rails.env = 'production'
      http_login("wrong", "wrong")

      get :index

      expect(response.code).to eq "401"
    ensure
      Rails.env = env
    end
  end

  def http_login(username, password)
    @request.env['HTTP_AUTHORIZATION'] =
      ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end
end
