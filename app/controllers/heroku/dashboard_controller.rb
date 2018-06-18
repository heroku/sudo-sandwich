module Heroku
  class DashboardController < ApplicationController
    before_action :session_auth
    skip_before_action :http_authenticate

    def show
      render plain: "Your Sandwich plan is currently: #{@sandwich.plan}"
    end

    private

    def session_auth
      find_sandwich
      id = session[:sandwich_id]

      if @sandwich.id != id
        render plain: "Authentication failed", status: 403
      end
    end

    def find_sandwich
      @sandwich = Sandwich.find_by(heroku_uuid: params[:id])
    end
  end
end
