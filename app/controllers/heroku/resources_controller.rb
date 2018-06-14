module Heroku
  class ResourcesController < ApplicationController
    def create
      logger.debug("RAW REQUEST BODY: #{request.raw_post}")
      heroku_uuid = params[:uuid]
      oauth_grant_code = params[:oauth_grant][:code]

      Sandwich.create!(
        heroku_uuid: heroku_uuid,
        oauth_grant_code: oauth_grant_code,
      )

      GrantCodeExchanger.new(
        heroku_uuid: heroku_uuid,
        oauth_grant_code: oauth_grant_code,
      ).run

      render(
        json: {
          id: heroku_uuid,
          config: {
            SUDO_SANDWICH_COMMAND: "Make me a PB&J!"
          },
          message: "Thanks for using Sudo Sandwich."
        },
        status: 200
      )
    end

    def destroy
      Sandwich.find_by(heroku_uuid: params[:id]).destroy!
      render status: 204
    end
  end
end
