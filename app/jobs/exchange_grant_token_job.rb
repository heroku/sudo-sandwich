class ExchangeGrantTokenJob < ApplicationJob
  queue_as :default

  def perform(sandwich_id:)
    GrantCodeExchanger.new(
      sandwich_id: sandwich_id,
    ).run

    if sandwich(sandwich_id).not_provisioned?
      unless ENV.has_key?('SKIP_ASYNC_FINALIZATION')
        ProvisionPlanJob.perform_later(sandwich_id: sandwich_id)
      end
    end
  end

  private

  def sandwich(sandwich_id)
    Sandwich.find(sandwich_id)
  end
end
