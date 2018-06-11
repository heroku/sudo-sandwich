module Heroku
  class ResourcesController < ApplicationController
    def create
      heroku_uuid = params[:uuid]

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
      render status: 204
    end
  end
end
