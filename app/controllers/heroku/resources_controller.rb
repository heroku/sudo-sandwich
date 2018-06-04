module Heroku
  class ResourcesController < ApplicationController
    def create
      heroku_uuid = params[:id]

      render(
        json: {
          id: heroku_uuid,
          config: {
            RADON_ADD_ON: "tubular!"
          },
          message: "Thanks for being rad and adding the rad-on add-on."
        },
        status: 200
      )
    end

    def destroy
      render status: 204
    end
  end
end
