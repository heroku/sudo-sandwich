module Heroku
  class ResourcesController < ApplicationController
    def create
      # if plan == Sandwich::BASE_PLAN # synchronous provisioning
      #   message = 'Thanks for using Sudo Sandwich. Your add-on is available for use immediately!'
      #   status = 200
      #   state = 'provisioned'
      #   payload = {
      #     config: {
      #       SUDO_SANDWICH_COMMAND: Sandwich::PLAN_CONFIG[plan],
      #     }
      #   }
      # else # async provisioning
      message = 'Sudo Sandwich is being provisioned. It will be available shortly.'
      status = 202
      state = 'provisioning'
      payload = {}
      # end

      sandwich = create_sandwich(state)
      # enqueue_token_exchange_job(sandwich)
      GrantCodeExchanger.new(
        sandwich_id: sandwich.id,
      ).run

      resp = Excon.new('https://api.heroku.com').get(
        path: "/addons/#{sandwich.heroku_uuid}/addon-attachments",
        headers: {
          'Accept' => 'application/vnd.heroku+json; version=3',
          'Authorization' => "Bearer #{sandwich.access_token}",
          'Content-Type' => 'application/json',
        }
      )
      logger.debug("sandwich ID: #{sandwich.id} response body #{resp.body}")
      render(
        json: {
          id: heroku_uuid,
          message: message
        }.merge(payload || {}),
        status: status
      )
    end

    def update
      sandwich = Sandwich.find_by(heroku_uuid: params[:id])
      original_plan = sandwich.plan
      new_plan = params[:plan]
      sandwich.update!(plan: new_plan)

      render json: {
        config: {
          SUDO_SANDWICH_COMMAND: Sandwich::PLAN_CONFIG[new_plan]
        },
        message: "Successfully changed from #{original_plan} to #{new_plan}"
      }

    end

    def destroy
      Sandwich.find_by(heroku_uuid: params[:id]).destroy!
      render status: 204
    end

    private

    def create_sandwich(state)
      Sandwich.create!(
        heroku_uuid: heroku_uuid,
        oauth_grant_code: oauth_grant_code,
        plan: plan,
        state: state,
      )
    end

    def enqueue_token_exchange_job(sandwich)
      ExchangeGrantTokenJob.perform_later(sandwich_id: sandwich.id)
    end

    def heroku_uuid
      params[:uuid]
    end

    def oauth_grant_code
      params[:oauth_grant][:code]
    end

    def plan
      params[:plan]
    end
  end
end
