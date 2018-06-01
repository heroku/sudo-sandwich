module Heroku
  class ResourcesController < ApplicationController
    def create
      heroku_uuid = params[:id]

      render(
        json: {
          id: heroku_uuid,
          config: {
            RAD_ON_ADD_ON: "tubular!"
          },
          message: "Thanks for being rad and adding the rad-on add-on."
        },
        status: 202
      )
    end
  end
end
