class ReportUsageJob < ApplicationJob
  queue_as :default

  def perform
    UsageReporter.new.run
  end
end
