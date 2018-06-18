class ApplicationController < ActionController::API
  include HttpBasicAuth

  def index
    render plain: "Hello world"
  end
end
