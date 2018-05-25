module Heroku
  class ResourcesController < ActionController::API
    def create
      render json: {}, status: 202
    end
  end
end
