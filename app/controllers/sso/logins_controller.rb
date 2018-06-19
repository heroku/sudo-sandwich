module Sso
  class LoginsController < ApplicationController
    skip_before_action :http_authenticate

    def create
      token = ResourceTokenCreator.new(
        heroku_uuid: heroku_uuid,
        timestamp: params[:timestamp],
      ).run

      if token != params[:resource_token]
        render status: 403
      else
        sandwich = Sandwich.find_by(heroku_uuid: heroku_uuid)
        session[:sandwich_id] = sandwich.id
        redirect_to heroku_dashboard_path(heroku_uuid)
      end
    end

    private

    def heroku_uuid
      @_heroku_uuid ||= params[:resource_id]
    end
  end
end
