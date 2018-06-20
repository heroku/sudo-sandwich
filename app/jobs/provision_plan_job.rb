class ProvisionPlanJob < ApplicationJob
  queue_as :default

  def perform(sandwich_id:)
    PlanProvisioner.new(sandwich_id: sandwich_id).run
  end
end
