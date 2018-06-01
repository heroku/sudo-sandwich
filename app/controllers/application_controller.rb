class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  http_basic_authenticate_with name: ENV["SLUG"], password: ENV["PASSWORD"]

  def index
    render plain: "Hello world"
  end
end
