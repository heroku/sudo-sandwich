class ProvisionPlanJob < ApplicationJob
  queue_as :default

  def perform(sandwich_id:)
    AsyncPlanProvisioner.new(sandwich_id: sandwich_id).run
  end
end
