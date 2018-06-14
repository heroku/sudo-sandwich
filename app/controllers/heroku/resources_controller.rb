module Heroku
  class ResourcesController < ApplicationController
    PLAN_COMMANDS = {
      "test" => "This is a test",
      "pbj" => "Make me a PB&J!",
      "blt" => "Make me a BLT!",
    }

    def create
      heroku_uuid = params[:uuid]
      oauth_grant_code = params[:oauth_grant][:code]
      plan = params[:plan]

      Sandwich.create!(
        heroku_uuid: heroku_uuid,
        oauth_grant_code: oauth_grant_code,
        plan: plan,
      )

      ExchangeGrantTokenJob.perform_later(
        heroku_uuid: heroku_uuid,
        oauth_grant_code: oauth_grant_code,
      )

      render(
        json: {
          id: heroku_uuid,
          config: {
            SUDO_SANDWICH_COMMAND: PLAN_COMMANDS[params[:plan]],
          },
          message: "Thanks for using Sudo Sandwich."
        },
        status: 200
      )
    end

    def update
      sandwich = Sandwich.find_by(heroku_uuid: params[:id])
      original_plan = sandwich.plan
      new_plan = params[:plan]
      sandwich.update!(plan: new_plan)

      render json: {
        config: {
          SUDO_SANDWICH_COMMAND: PLAN_COMMANDS[params[:plan]]
        },
        message: "Successfully changed from #{original_plan} to #{new_plan}"
      }

    end

    def destroy
      Sandwich.find_by(heroku_uuid: params[:id]).destroy!
      render status: 204
    end
  end
end
