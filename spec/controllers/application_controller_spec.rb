require 'rails_helper'

describe ApplicationController do
  it "returns a 200 when correct basic auth credentials used" do
    http_login(ENV['SLUG'], ENV['PASSWORD'])

    get :index

    expect(response.code).to eq "200"
  end

  it "returns a 401 with incorrect basic auth credentials used" do
    http_login("wrong", "wrong")

    get :index

    expect(response.code).to eq "401"
  end
end
