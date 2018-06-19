class ExchangeGrantTokenJob < ApplicationJob
  queue_as :default

  def perform(sandwich_id:, sandwich_plan:)
    GrantCodeExchanger.new(
      sandwich_id: sandwich_id,
    ).run

    if sandwich_plan != Sandwich::BASE_PLAN
      ProvisionPlanJob.perform_later(sandwich_id: sandwich_id)
    end
  end
end
